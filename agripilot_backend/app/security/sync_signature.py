import hashlib
import hmac
import time
from fastapi import HTTPException, status
import logging

logger = logging.getLogger(__name__)

class SyncSignatureValidator:
    """
    Validates offline sync payloads to prevent replay attacks and tampering.
    """
    
    # In production, device public keys would be fetched from DB
    # For MVP, we use a shared secret mechanism for HMAC
    SHARED_SYNC_SECRET = b"agripilot_offline_super_secret"
    
    @classmethod
    def validate_signature(cls, payload: str, timestamp: int, nonce: str, signature: str):
        # 1. Timestamp validation (Prevent Replay Attacks > 5 mins old)
        current_time = int(time.time())
        if abs(current_time - timestamp) > 300:
            logger.error("Sync rejected: Timestamp drift > 5 minutes (Replay attack?)")
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Signature expired")
            
        # 2. Reconstruct hash
        message = f"{payload}:{timestamp}:{nonce}".encode()
        expected_sig = hmac.new(cls.SHARED_SYNC_SECRET, message, hashlib.sha256).hexdigest()
        
        # 3. Constant time compare
        if not hmac.compare_digest(expected_sig, signature):
            logger.error("Sync rejected: Invalid cryptographic signature.")
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid signature")
            
        return True
