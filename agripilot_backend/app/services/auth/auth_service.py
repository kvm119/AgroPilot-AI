"""
Auth service — coordinates registration, login, and token refresh.
Business logic layer between the router and the repository/services.
"""
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from ...repositories.user_repository import create_user, get_user_by_email
from .password_service import hash_password, verify_password
from .jwt_service import create_access_token, create_refresh_token, decode_token


def register_user(db: Session, name: str, email: str, password: str) -> dict:
    """Register a new user. Raises 409 if email already exists."""
    existing = get_user_by_email(db, email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this email already exists."
        )

    hashed = hash_password(password)
    create_user(db, name=name, email=email, password_hash=hashed)
    return {"message": "Registration successful"}


def login_user(db: Session, email: str, password: str) -> dict:
    """Authenticate user credentials and return JWT tokens."""
    user = get_user_by_email(db, email)
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password."
        )

    token_data = {"sub": str(user.id), "email": user.email}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "Bearer"
    }


def refresh_access_token(refresh_token_str: str) -> dict:
    """Validate a refresh token and issue a new access token."""
    payload = decode_token(refresh_token_str)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token."
        )

    token_data = {"sub": payload["sub"], "email": payload["email"]}
    new_access = create_access_token(token_data)
    return {
        "access_token": new_access,
        "refresh_token": refresh_token_str,
        "token_type": "Bearer"
    }
