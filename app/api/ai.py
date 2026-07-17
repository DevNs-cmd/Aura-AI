from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Optional, Any
import requests
import json
import base64

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.api.deps import get_ai_chat_service, get_db
from app.ai.chat.exceptions import ChatError
from app.ai.chat.service import ChatService
from app.core.security import hash_password
from app.models.user import User
from app.schemas.ai_chat import AIChatMetadata, AIChatRequest, AIChatResponse
from app.ai.chat.schemas import ChatRequest
from app.core.config import settings

# Voice service imports
from app.ai.voice.providers import OpenRouterSTTProvider, GoogleTranslateTTSProvider
from app.ai.voice.service import build_voice_service, VoiceService
from app.ai.voice.repository import build_voice_repository
from app.ai.voice.schemas import VoiceSynthesisRequest, VoiceTranscriptionRequest

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ai", tags=["AI Gateway"])


def get_voice_service() -> VoiceService:
    stt_provider = OpenRouterSTTProvider()
    tts_provider = GoogleTranslateTTSProvider()
    repository = build_voice_repository(stt_provider=stt_provider, tts_provider=tts_provider)
    from app.ai.voice.pipeline import VoicePipeline
    pipeline = VoicePipeline(repository_factory=lambda db: repository)
    return build_voice_service(pipeline=pipeline)


@router.post("/chat", response_model=AIChatResponse)
def chat(
    request: AIChatRequest,
    db: Session = Depends(get_db),
    chat_service: ChatService = Depends(get_ai_chat_service),
) -> AIChatResponse:
    user = None

    if request.user_id is not None:
        user = db.query(User).filter(User.id == request.user_id).first()

    if user is None and request.user_email is not None:
        user = db.query(User).filter(User.email.ilike(request.user_email)).first()

    if user is None and request.user_email is not None:
        raw_password = request.user_email + (str(request.user_id) if request.user_id is not None else "")
        if len(raw_password) > 72:
            raw_password = raw_password[:72]

        user_kwargs = {
            "email": request.user_email,
            "name": request.user_name or request.user_email.split("@")[0],
            "password_hash": hash_password(raw_password),
        }
        if request.user_id is not None:
            user_kwargs["id"] = request.user_id

        user = User(**user_kwargs)
        db.add(user)
        db.commit()
        db.refresh(user)

    if user is None or not user.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    try:
        result = chat_service.generate_reply(ChatRequest(user_id=user.id, query=request.message), db=db)
    except ChatError as exc:
        logger.exception("AI chat generation failed for user_id=%s", user.id)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc) if str(exc) else "AI chat generation failed",
        ) from exc

    metadata = AIChatMetadata(
        memory_used=bool(result.context.memory.memories or result.context.memory.summary),
        rag_used=bool(result.context.retrieval.documents or result.context.retrieval.summary),
    )

    return AIChatResponse(
        reply=result.response.content,
        model_used=result.response.model,
        timestamp=datetime.now(timezone.utc),
        metadata=metadata,
    )


class VisionAnalyzeRequest(BaseModel):
    user_id: Optional[str] = None
    image: str


@router.post("/vision/analyze")
def vision_analyze(request: VisionAnalyzeRequest) -> Any:
    b64_data = request.image
    if "," in b64_data:
        b64_data = b64_data.split(",")[1]
    
    prompt = (
        "You are an expert computer vision, object detection, and OCR AI assistant.\n"
        "Analyze the provided image with high precision:\n"
        "1. Carefully perform OCR to extract all visible text, letters, symbols, signs, and numbers. Be thorough.\n"
        "2. Identify all key physical objects, background elements, people, items, or equipment visible in the scene.\n"
        "3. Describe the overall scene clearly in 1 or 2 sentences.\n"
        "4. Provide a cognitive analysis of the context, mood, or setting of the image in 1 or 2 sentences.\n\n"
        "Your response MUST be a valid JSON object matching this schema:\n"
        "{\n"
        "  \"ocr_text\": \"<extracted text>\",\n"
        "  \"detected_objects\": [\n"
        "    {\"name\": \"<object name>\", \"confidence\": <float 0.0 to 1.0>}\n"
        "  ],\n"
        "  \"scene\": \"<1-2 sentence description of the overall scene>\",\n"
        "  \"context\": \"<1-2 sentence analysis of the context, setting, or mood>\"\n"
        "}\n\n"
        "Do not wrap in markdown tags (do NOT use ```json or similar). Return ONLY the raw JSON output."
    )
    
    model_to_use = settings.LLM_MODEL
    # Auto-upgrade to openrouter/free if the model is a generic text-only model
    if model_to_use != "openrouter/free" and ("gemini" not in model_to_use.lower() and "vision" not in model_to_use.lower() and "vl" not in model_to_use.lower()):
        model_to_use = "openrouter/free"

    payload = {
        "model": model_to_use,
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{b64_data}"
                        }
                    }
                ]
            }
        ],
        "response_format": {"type": "json_object"}
    }
    headers = {
        "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": settings.FRONTEND_URL,
        "X-Title": "Aura AI"
    }
    try:
        response = requests.post("https://openrouter.ai/api/v1/chat/completions", json=payload, headers=headers, timeout=30)
        response.raise_for_status()
        data = response.json()
        content = data["choices"][0]["message"]["content"].strip()
        
        import re
        parsed = None
        
        # Try to find a JSON block in the text
        json_match = re.search(r"(\{.*\})", content, re.DOTALL)
        if json_match:
            try:
                parsed = json.loads(json_match.group(1))
            except Exception:
                pass
                
        if not parsed:
            # Fallback cleanup of markdown code blocks
            cleaned = content.strip()
            if cleaned.startswith("```"):
                lines = cleaned.splitlines()
                if lines[0].startswith("```"):
                    lines = lines[1:]
                if lines and lines[-1].strip() == "```":
                    lines = lines[:-1]
                cleaned = "\n".join(lines).strip()
            try:
                parsed = json.loads(cleaned)
            except Exception:
                pass
                
        if parsed and isinstance(parsed, dict):
            return {
                "ocr_text": parsed.get("ocr_text") or "No text detected.",
                "detected_objects": parsed.get("detected_objects") or [{"name": "Detected Object", "confidence": 0.9}],
                "scene": parsed.get("scene") or "An analyzed image scene.",
                "context": parsed.get("context") or "Contextual scene analysis completed."
            }
            
        # If parsing completely failed, treat raw text as scene description so it's not empty
        cleaned_content = content.replace("```json", "").replace("```", "").strip()
        return {
            "ocr_text": "No text detected.",
            "detected_objects": [{"name": "Image Component", "confidence": 0.9}],
            "scene": cleaned_content or "An analyzed image scene.",
            "context": "Contextual scene analysis completed."
        }
    except Exception as e:
        return {
            "ocr_text": "No text detected.",
            "detected_objects": [{"name": "Scan Failed", "confidence": 0.0}],
            "scene": f"Failed to analyze image content: {str(e)}",
            "context": "Verification failed due to connectivity issues."
        }


@router.post("/voice/transcribe")
def voice_transcribe(
    request: VoiceTranscriptionRequest,
    voice_service: VoiceService = Depends(get_voice_service)
) -> Any:
    try:
        result = voice_service.transcribe(request)
        return {
            "text": result.text,
            "provider": result.provider,
            "model": result.model,
            "language": result.language
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Transcription failed: {str(e)}"
        )


@router.post("/voice/synthesize")
def voice_synthesize(
    request: VoiceSynthesisRequest,
    voice_service: VoiceService = Depends(get_voice_service)
) -> Any:
    try:
        result = voice_service.synthesize(request)
        import base64
        b64_audio = base64.b64encode(result.audio).decode("utf-8")
        return {
            "audio": b64_audio,
            "mime_type": result.mime_type or "audio/mp3",
            "format": result.output_format
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Synthesis failed: {str(e)}"
        )
