"""
Authentication router — handles registration, login, logout, refresh, and password reset.
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..core.database import get_db
from ..core.dependencies import get_current_user
from ..models.user import User
from ..schemas.auth import (
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    ForgotPasswordRequest,
    ResetPasswordRequest,
    UserProfileResponse,
    MessageResponse,
)
from ..services.auth.auth_service import register_user, login_user, refresh_access_token

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=MessageResponse)
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    """Register a new user with email and password."""
    return register_user(db, name=payload.name, email=payload.email, password=payload.password)


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    """Authenticate with email and password, returns JWT tokens."""
    return login_user(db, email=payload.email, password=payload.password)


@router.post("/logout", response_model=MessageResponse)
def logout(current_user: User = Depends(get_current_user)):
    """
    Logout the current user.
    Client-side: delete stored tokens.
    Server-side: token blacklisting can be added in a future sprint.
    """
    return {"message": "Logged out successfully"}


@router.post("/refresh", response_model=TokenResponse)
def refresh(refresh_token: str, db: Session = Depends(get_db)):
    """Exchange a valid refresh token for a new access token."""
    return refresh_access_token(refresh_token)


@router.post("/forgot-password", response_model=MessageResponse)
def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    """
    Request a password reset.
    Currently mocked for MVP — always returns success.
    In production, this would send a reset email.
    """
    return {"message": "If a matching account exists, a reset link has been sent."}


@router.post("/reset-password", response_model=MessageResponse)
def reset_password(payload: ResetPasswordRequest, db: Session = Depends(get_db)):
    """
    Reset a user's password using a valid reset token.
    Currently mocked for MVP.
    """
    return {"message": "Password has been reset successfully."}


@router.get("/me", response_model=UserProfileResponse)
def get_me(current_user: User = Depends(get_current_user)):
    """Return the authenticated user's profile."""
    return UserProfileResponse(
        id=str(current_user.id),
        name=current_user.name,
        email=current_user.email,
        is_verified=current_user.is_verified,
        language=current_user.language,
    )
