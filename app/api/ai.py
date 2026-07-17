from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_ai_chat_service, get_db, get_voice_service
from app.ai.chat.exceptions import ChatError
from app.ai.chat.service import ChatService
from app.core.security import hash_password
from app.models.user import User
from app.schemas.ai_chat import AIChatMetadata, AIChatRequest, AIChatResponse
from app.ai.chat.schemas import ChatRequest

router = APIRouter(prefix="/ai", tags=["AI Gateway"])


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


import base64
import json
import requests
from typing import Optional, List, Dict, Any
from pydantic import BaseModel
from app.core.config import settings

class VisionAnalyzeRequest(BaseModel):
    user_id: Optional[str] = None
    image: str  # Base64 encoded string

class VoiceTranscribeRequest(BaseModel):
    user_id: Optional[str] = None
    audio: str  # Base64 encoded string
    mime_type: str

class VoiceSynthesizeRequest(BaseModel):
    user_id: Optional[str] = None
    text: str
    language: Optional[str] = None


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
    # Auto-upgrade to a free multimodal model if the configured model is text-only or generic free router
    if model_to_use in {"openrouter/free", "free"} or ("gemini" not in model_to_use.lower() and "vision" not in model_to_use.lower()):
        model_to_use = "google/gemini-2.5-flash:free"

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
        ]
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
                "ocr_text": parsed.get("ocr_text", ""),
                "detected_objects": parsed.get("detected_objects", []),
                "scene": parsed.get("scene", ""),
                "context": parsed.get("context", "")
            }
            
        # If parsing completely failed, treat raw text as ocr_text
        return {
            "ocr_text": content,
            "detected_objects": [],
            "scene": "",
            "context": ""
        }
    except Exception as e:
        return {
            "ocr_text": "Failed to analyze image content.",
            "detected_objects": [
                {"name": f"Error: {str(e)}", "confidence": 0.0}
            ],
            "scene": "",
            "context": ""
        }


@router.post("/voice/transcribe")
def voice_transcribe(
    request: VoiceTranscribeRequest,
    voice_service: Any = Depends(get_voice_service),
) -> Any:
    # Clean base64 string
    b64_data = request.audio
    if "," in b64_data:
        b64_data = b64_data.split(",")[1]
    
    audio_bytes = base64.b64decode(b64_data)
    
    from app.ai.voice.schemas import VoiceTranscriptionRequest
    voice_req = VoiceTranscriptionRequest(
        audio=audio_bytes,
        mime_type=request.mime_type
    )
    result = voice_service.transcribe(voice_req)
    return {
        "text": result.text,
        "provider": result.provider,
        "model": result.model,
        "language": result.language
    }


@router.post("/voice/synthesize")
def voice_synthesize(
    request: VoiceSynthesizeRequest,
    voice_service: Any = Depends(get_voice_service),
) -> Any:
    from app.ai.voice.schemas import VoiceSynthesisRequest
    voice_req = VoiceSynthesisRequest(
        text=request.text,
        language=request.language
    )
    result = voice_service.synthesize(voice_req)
    audio_b64 = base64.b64encode(result.audio).decode("utf-8")
    return {
        "audio": audio_b64,
        "mime_type": result.mime_type,
        "output_format": result.output_format
    }

