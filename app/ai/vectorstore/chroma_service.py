import os
from typing import List, Dict, Any, Optional
from dotenv import load_dotenv
import chromadb

load_dotenv()

CHROMA_HOST = os.getenv("CHROMA_HOST", "localhost")
CHROMA_PORT = int(os.getenv("CHROMA_PORT", "8001"))

client = chromadb.HttpClient(
    host=CHROMA_HOST,
    port=CHROMA_PORT
)

memory_collection = client.get_or_create_collection(name="aura_memories")
document_collection = client.get_or_create_collection(name="aura_documents")
journal_collection = client.get_or_create_collection(name="aura_journals")


# -------------------------------
# 1. MEMORY VECTORS
# -------------------------------

def add_memory_vector(
    user_id: str,
    memory_id: str,
    content: str,
    memory_type: str
) -> str:
    """
    Stores user facts, preferences, goals, and long-term memories in ChromaDB.
    PostgreSQL stores the actual memory row.
    ChromaDB stores the searchable vector.
    """

    embedding_id = f"memory_{memory_id}"

    memory_collection.add(
        ids=[embedding_id],
        documents=[content],
        metadatas=[
            {
                "user_id": user_id,
                "source_id": memory_id,
                "type": memory_type
            }
        ]
    )

    return embedding_id


def search_memory_vectors(
    user_id: str,
    query: str,
    limit: int = 5
) -> List[Dict[str, Any]]:
    """
    Searches memories only for one user.
    """

    results = memory_collection.query(
        query_texts=[query],
        n_results=limit,
        where={"user_id": user_id}
    )

    return format_chroma_results(results)


def delete_memory_vector(memory_id: str):
    embedding_id = f"memory_{memory_id}"
    memory_collection.delete(ids=[embedding_id])


# -------------------------------
# 2. DOCUMENT VECTORS
# -------------------------------

def add_document_chunk_vector(
    user_id: str,
    document_id: str,
    chunk_text: str,
    chunk_index: int,
    file_name: str
) -> str:
    """
    Stores PDF/DOCX/notes text chunks in ChromaDB.
    PostgreSQL stores document file info.
    ChromaDB stores each searchable text chunk.
    """

    embedding_id = f"document_{document_id}_chunk_{chunk_index}"

    document_collection.add(
        ids=[embedding_id],
        documents=[chunk_text],
        metadatas=[
            {
                "user_id": user_id,
                "document_id": document_id,
                "chunk_index": chunk_index,
                "file_name": file_name
            }
        ]
    )

    return embedding_id


def search_document_vectors(
    user_id: str,
    query: str,
    limit: int = 5
) -> List[Dict[str, Any]]:
    """
    Searches document chunks only for one user.
    """

    results = document_collection.query(
        query_texts=[query],
        n_results=limit,
        where={"user_id": user_id}
    )

    return format_chroma_results(results)


def delete_document_vectors(document_id: str):
    """
    Deletes all chunks of one document.
    """

    existing = document_collection.get(
        where={"document_id": document_id}
    )

    ids = existing.get("ids", [])

    if ids:
        document_collection.delete(ids=ids)


# -------------------------------
# 3. JOURNAL VECTORS
# -------------------------------

def add_journal_vector(
    user_id: str,
    journal_id: str,
    content: str,
    mood: Optional[str] = None
) -> str:
    """
    Stores journal entries and mood-based searchable reflections.
    PostgreSQL stores actual journal data.
    ChromaDB stores searchable vector data.
    """

    embedding_id = f"journal_{journal_id}"

    journal_collection.add(
        ids=[embedding_id],
        documents=[content],
        metadatas=[
            {
                "user_id": user_id,
                "journal_id": journal_id,
                "mood": mood or "neutral"
            }
        ]
    )

    return embedding_id


def search_journal_vectors(
    user_id: str,
    query: str,
    limit: int = 5
) -> List[Dict[str, Any]]:
    """
    Searches journal entries only for one user.
    """

    results = journal_collection.query(
        query_texts=[query],
        n_results=limit,
        where={"user_id": user_id}
    )

    return format_chroma_results(results)


def delete_journal_vector(journal_id: str):
    embedding_id = f"journal_{journal_id}"
    journal_collection.delete(ids=[embedding_id])


# -------------------------------
# COMMON FORMATTER
# -------------------------------

def format_chroma_results(results: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Converts ChromaDB output into clean list format.
    """

    formatted = []

    ids = results.get("ids", [[]])[0]
    documents = results.get("documents", [[]])[0]
    metadatas = results.get("metadatas", [[]])[0]
    distances = results.get("distances", [[]])[0]

    for index, item_id in enumerate(ids):
        formatted.append(
            {
                "embedding_id": item_id,
                "content": documents[index],
                "metadata": metadatas[index],
                "distance": distances[index] if index < len(distances) else None
            }
        )

    return formatted


# -------------------------------
# HEALTH CHECK
# -------------------------------

def chroma_health_check():
    collections = client.list_collections()

    return {
        "status": "connected",
        "collections": [collection.name for collection in collections]
    }