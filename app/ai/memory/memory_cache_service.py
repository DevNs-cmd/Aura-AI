from app.ai.memory.redis_service import get_memory_cache, set_memory_cache


async def retrieve_memory(user_id: str, query: str):
    cached = await get_memory_cache(user_id, query)

    if cached:
        print("Memory loaded from Redis cache")
        return cached

    # Later this will come from ChromaDB search
    memories = [
        {
            "content": "User prefers concise answers",
            "score": 0.91
        }
    ]

    await set_memory_cache(user_id, query, memories)

    print("Memory loaded from ChromaDB and saved to Redis cache")
    return memories