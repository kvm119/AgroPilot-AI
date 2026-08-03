import os
import logging
from typing import Optional

logger = logging.getLogger(__name__)

class SecretManager:
    """
    Wrapper for retrieving API keys. 
    In production, this integrates with Google Secret Manager or HashiCorp Vault.
    """
    
    @classmethod
    def get_secret(cls, secret_name: str) -> Optional[str]:
        # Local DEV fallback
        value = os.environ.get(secret_name)
        
        if not value:
            logger.warning(f"Secret '{secret_name}' not found in environment.")
            
        return value
