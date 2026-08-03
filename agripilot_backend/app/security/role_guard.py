from fastapi import HTTPException, status, Depends
from typing import List
import logging
from .auth_guard import get_current_user

logger = logging.getLogger(__name__)

# Mock Role DB
USER_ROLES = {
    "admin_user": "ADMIN",
    "farmer_user_1": "FARMER"
}

class RequireRole:
    """
    Dependency injector for RBAC.
    """
    def __init__(self, allowed_roles: List[str]):
        self.allowed_roles = allowed_roles

    async def __call__(self, user_id: str = Depends(get_current_user)):
        user_role = USER_ROLES.get(user_id, "FARMER")
        
        if "ADMIN" in self.allowed_roles and user_role == "ADMIN":
            return user_id
            
        if user_role not in self.allowed_roles:
            logger.warning(f"Access Denied: User {user_id} with role {user_role} attempted to access restricted endpoint.")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action."
            )
            
        return user_id
