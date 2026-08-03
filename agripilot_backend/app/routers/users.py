from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..core.database import get_db
from ..core.dependencies import get_current_user
from ..models.user import User as UserModel
from ..schemas.auth import UserProfileResponse

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserProfileResponse)
def get_current_user_profile(
    current_user: UserModel = Depends(get_current_user),
):
    """
    Return the currently authenticated user's profile.
    Uses JWT Bearer token for authentication.
    """
    return UserProfileResponse(
        id=str(current_user.id),
        name=current_user.name,
        email=current_user.email,
        is_verified=current_user.is_verified,
        language=current_user.language,
    )
