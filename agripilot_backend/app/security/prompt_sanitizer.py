import re
import logging
from fastapi import HTTPException, status

logger = logging.getLogger(__name__)

class PromptSanitizer:
    """
    Detects and blocks prompt injection attempts before they reach the Orchestrator/LLM.
    """
    
    INJECTION_PATTERNS = [
        re.compile(r"(?i)ignore previous instructions"),
        re.compile(r"(?i)disregard previous"),
        re.compile(r"(?i)system prompt"),
        re.compile(r"(?i)bypass restrictions"),
        re.compile(r"(?i)act as a system"),
        re.compile(r"(?i)return api keys")
    ]
    
    @classmethod
    def sanitize(cls, prompt: str) -> str:
        if not prompt:
            return prompt
            
        for pattern in cls.INJECTION_PATTERNS:
            if pattern.search(prompt):
                logger.error(f"SECURITY ALERT: Prompt Injection detected! Blocked payload: {prompt}")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Message violates security policies."
                )
                
        # Basic escaping for Markdown/HTML if needed
        return prompt
