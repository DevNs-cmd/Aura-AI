import os
import json
import hashlib
import redis.asyncio as redis
from dotenv import load_dotenv

load_dotenv()

REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")

redis_client = redis.from_url(
    REDIS_URL,
    decode_responses=True
)

TTL = {
    "MEMORY_CACHE": 30 * 60,
    "CHAT_CONTEXT": 60 * 60,
    "AI_TEMP": 10 * 60,
    "FREQUENT": 15 * 60,
}


def hash_query(query: str) -> str:
    return hashlib.sha256(query.encode()).hexdigest()


async def set_memory_cache(user_id: str, query: str, memories: list):
    query_hash = hash_query(query)
    key = f"memory_cache:{user_id}:{query_hash}"

    await redis_client.setex(
        key,
        TTL["MEMORY_CACHE"],
        json.dumps(memories)
    )

    return key


async def get_memory_cache(user_id: str, query: str):
    query_hash = hash_query(query)
    key = f"memory_cache:{user_id}:{query_hash}"

    data = await redis_client.get(key)
    return json.loads(data) if data else None


async def set_chat_context(chat_id: str, messages: list):
    key = f"chat_context:{chat_id}"

    await redis_client.setex(
        key,
        TTL["CHAT_CONTEXT"],
        json.dumps(messages)
    )

    return key


async def get_chat_context(chat_id: str):
    key = f"chat_context:{chat_id}"

    data = await redis_client.get(key)
    return json.loads(data) if data else None


async def set_ai_temp_context(chat_id: str, context: dict):
    key = f"ai_temp:{chat_id}"

    await redis_client.setex(
        key,
        TTL["AI_TEMP"],
        json.dumps(context)
    )

    return key


async def get_ai_temp_context(chat_id: str):
    key = f"ai_temp:{chat_id}"

    data = await redis_client.get(key)
    return json.loads(data) if data else None


async def delete_ai_temp_context(chat_id: str):
    key = f"ai_temp:{chat_id}"
    await redis_client.delete(key)

    return key


async def redis_health_check():
    pong = await redis_client.ping()

    return {
        "status": "connected" if pong else "not connected"
    }