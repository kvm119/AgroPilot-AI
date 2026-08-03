import logging
from fastapi import Request, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

logger = logging.getLogger(__name__)

security = HTTPBearer()

# In a real environment, this would be a Redis lookup
REVOKED_TOKENS = set()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    token = credentials.credentials
    
    if token in REVOKED_TOKENS:
        logger.warning(f"Attempt to use revoked token: {token[:10]}...")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has been revoked"
        )
        
    # Mock JWT validation logic (normally Firebase Admin SDK)
    if not token or len(token) < 10:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials"
        )
        
    # Returning mocked user_id based on token for now
    if token == "admin_token_123":
        return "admin_user"
    return "farmer_user_1"

def revoke_token(token: str):
    REVOKED_TOKENS.add(token)
