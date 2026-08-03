from typing import List, Dict, Any
from ...repositories.memory_repository import MemoryRepository

class MemoryService:
    """
    Advanced memory system wrapping persistent PostgreSQL storage via MemoryRepository.
    """
    def __init__(self, repo: MemoryRepository):
        self.repo = repo

    def add_message(self, conversation_id: str, user_id: str, role: str, content: str):
        # Ensure conversation exists before inserting a message
        self.repo.get_or_create_conversation(conversation_id, user_id)
        self.repo.append_message(conversation_id, role, content)

    def get_history(self, conversation_id: str) -> List[Dict[str, str]]:
        # Database index optimization allows us to slice exactly 20 without pulling the whole table
        return self.repo.load_history(conversation_id, limit=20)
        
    def update_metadata(self, user_id: str, key: str, value: Any):
        # Map string keys to DB entity types
        self.repo.save_entity(user_id=user_id, entity_type=key, value=str(value))

    def get_metadata(self, user_id: str) -> Dict[str, Any]:
        entities = self.repo.get_entities(user_id)
        # Re-construct dictionary format for compatibility with existing reasoning engine
        metadata = {}
        for e in entities:
            if e["type"] not in metadata:
                metadata[e["type"]] = []
            metadata[e["type"]].append(e["value"])
        return metadata

# Note: The singleton pattern is dropped. Dependency Injection must provide instances now.
