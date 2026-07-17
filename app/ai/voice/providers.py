from __future__ import annotations

import base64
import urllib.parse
from typing import Any
import requests

from app.core.config import settings


class OpenRouterSTTProvider:
    """Uses OpenRouter's multimodal capabilities to transcribe audio."""

    def transcribe(
        self,
        audio: bytes,
        mime_type: str,
        language: str | None = None,
        model: str | None = None,
        prompt: str | None = None,
        **kwargs: Any,
    ) -> dict[str, Any]:
        try:
            # Encode audio to base64
            audio_b64 = base64.b64encode(audio).decode("utf-8")
            
            model_to_use = model or settings.LLM_MODEL
            # Auto-upgrade to gemini for audio transcription as well
            if model_to_use in {"openrouter/free", "free"} or ("gemini" not in model_to_use.lower() and "vision" not in model_to_use.lower()):
                model_to_use = "google/gemini-2.5-flash:free"

            system_prompt = (
                "You are an accurate audio transcription assistant. "
                "Transcribe the audio provided exactly as spoken. "
                "Do not add any preamble, explanations, notes, or markdown. "
                "Return ONLY the transcribed text. If the audio is silent or contains no speech, return an empty string."
            )
            
            payload = {
                "model": model_to_use,
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": system_prompt},
                            {
                                "type": "image_url",  # Some multimodal models accept audio data inside the image_url schema
                                "image_url": {
                                    "url": f"data:{mime_type};base64,{audio_b64}"
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
            
            response = requests.post(
                "https://openrouter.ai/api/v1/chat/completions",
                json=payload,
                headers=headers,
                timeout=30,
            )
            response.raise_for_status()
            res_data = response.json()
            text = res_data["choices"][0]["message"]["content"].strip()
            
            return {
                "text": text,
                "provider": "openrouter",
                "model": model_to_use,
                "language": language or "en",
            }
        except Exception as e:
            raise RuntimeError(f"Speech-to-Text transcription failed: {str(e)}") from e


class GoogleTranslateTTSProvider:
    """Uses the free, public Google Translate TTS endpoint to generate high quality speech."""

    def synthesize(
        self,
        text: str,
        language: str | None = None,
        voice: str | None = None,
        model: str | None = None,
        **kwargs: Any,
    ) -> bytes:
        lang = language or "en"
        # Split text into chunks if it is too long (Google TTS limit is ~200 chars)
        chunks = [text[i:i+150] for i in range(0, len(text), 150)]
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            )
        }
        
        import concurrent.futures

        def fetch_chunk(chunk: str) -> bytes:
            if not chunk.strip():
                return b""
            encoded_text = urllib.parse.quote(chunk)
            url = f"https://translate.google.com/translate_tts?ie=UTF-8&tl={lang}&client=tw-ob&q={encoded_text}"
            try:
                response = requests.get(url, headers=headers, timeout=10)
                response.raise_for_status()
                return response.content
            except Exception:
                return b""

        # Fetch chunks concurrently in parallel threads
        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            results = list(executor.map(fetch_chunk, chunks))

        audio_content = bytearray()
        for res_bytes in results:
            audio_content.extend(res_bytes)
                
        if not audio_content:
            raise RuntimeError("Text-to-Speech synthesis failed to generate audio output.")
            
        return bytes(audio_content)
