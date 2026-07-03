import logging
import requests
from sqlalchemy.orm import Session
from app.core.config import settings
from app.models.chat import ChatSession, Message
from app.models.memory import Memory
from app.models.user import User

logger = logging.getLogger(__name__)

OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"


def _get_recent_history(db: Session, session: ChatSession, limit: int = 10) -> list[dict]:
    messages = (
        db.query(Message)
        .filter(Message.session_id == session.id)
        .order_by(Message.created_at.desc())
        .limit(limit)
        .all()
    )
    messages.reverse()
    return [{"role": m.role, "content": m.content} for m in messages]


def _get_user_memory_context(db: Session, user: User) -> str:
    memories = db.query(Memory).filter(Memory.user_id == user.id).limit(20).all()
    if not memories:
        return ""
    facts = "; ".join(f"{m.key}: {m.value}" for m in memories)
    return f"Known facts about the user: {facts}"


def generate_ai_reply(db: Session, user: User, session: ChatSession, user_message: str) -> str:
    """D1 LLM Orchestrator + D4 Context Manager: merges chat history & memory, calls LLM."""
    system_prompt = "You are Aura, a helpful and warm personal AI companion."
    memory_context = _get_user_memory_context(db, user)
    if memory_context:
        system_prompt += f"\n\n{memory_context}"

    history = _get_recent_history(db, session)
    messages = [{"role": "system", "content": system_prompt}] + history

    if not settings.OPENROUTER_API_KEY:
        logger.warning("OPENROUTER_API_KEY not set — returning dev-echo response")
        return f"[dev-echo] {user_message}"

    try:
        response = requests.post(
            OPENROUTER_URL,
            headers={
                "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
                "Content-Type": "application/json",
                # OpenRouter recommends these for free-tier rate limits / attribution
                "HTTP-Referer": settings.FRONTEND_URL or "http://localhost:5173",
                "X-Title": "Aura AI",
            },
            json={
                "model": settings.LLM_MODEL,
                "messages": messages,
            },
            timeout=30,
        )
        response.raise_for_status()
        data = response.json()

        choices = data.get("choices")
        if not choices:
            logger.error("OPENROUTER: no choices in response: %s", data)
            return "Sorry, I'm having trouble reaching the AI service right now. Please try again."

        return choices[0]["message"]["content"]

    except requests.exceptions.Timeout:
        logger.error("OPENROUTER: request timed out")
        return "Sorry, the AI service took too long to respond. Please try again."

    except requests.exceptions.HTTPError as e:
        status = e.response.status_code if e.response is not None else "unknown"
        body = e.response.text if e.response is not None else ""
        logger.error("OPENROUTER HTTP ERROR %s: %s", status, body)

        if status == 401:
            return "Sorry, the AI service credentials are invalid. Please contact support."
        if status == 429:
            return "Sorry, I'm getting too many requests right now. Please try again in a moment."
        if status == 404:
            return "Sorry, the AI model is currently unavailable. Please try again later."
        return "Sorry, I'm having trouble reaching the AI service right now. Please try again."

    except requests.exceptions.RequestException as e:
        logger.error("OPENROUTER: request failed: %s", e)
        return "Sorry, I'm having trouble reaching the AI service right now. Please try again."

    except (KeyError, IndexError, ValueError) as e:
        logger.error("OPENROUTER: unexpected response format: %s", e)
        return "Sorry, something went wrong processing the AI response. Please try again."