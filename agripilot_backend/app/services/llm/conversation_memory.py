from typing import List, Dict

class ConversationMemory:
    """
    Lightweight FIFO in-memory store for conversation history.
    Limits to the last N messages to prevent context window overflow.
    Designed to be easily swapped with Redis in production.
    """
    def __init__(self, max_history: int = 10):
        self.max_history = max_history
        # Structure: { "conversation_id": [{"role": "user", "content": "..."}] }
        self._store: Dict[str, List[Dict[str, str]]] = {}

    def add_message(self, conversation_id: str, role: str, content: str):
        if conversation_id not in self._store:
            self._store[conversation_id] = []
            
        self._store[conversation_id].append({"role": role, "content": content})
        
        # Enforce FIFO limit
        if len(self._store[conversation_id]) > self.max_history:
            # Remove the oldest message (index 0)
            self._store[conversation_id].pop(0)

    def get_history(self, conversation_id: str) -> List[Dict[str, str]]:
        return self._store.get(conversation_id, [])

    def clear(self, conversation_id: str):
        if conversation_id in self._store:
            del self._store[conversation_id]

# Singleton instance for the mock backend
_memory_instance = ConversationMemory(max_history=10)

def get_conversation_memory() -> ConversationMemory:
    return _memory_instance
