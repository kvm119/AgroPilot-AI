from typing import Optional
from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    """Schema for user registration."""
    name: str = Field(..., min_length=2, max_length=100, description="User's full name")
    email: EmailStr = Field(..., description="User's email address")
    password: str = Field(..., min_length=8, max_length=128, description="Password (min 8 chars)")


class LoginRequest(BaseModel):
    """Schema for user login."""
    email: EmailStr = Field(..., description="User's email address")
    password: str = Field(..., description="User's password")


class TokenResponse(BaseModel):
    """Schema for JWT token response."""
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"


class ForgotPasswordRequest(BaseModel):
    """Schema for forgot password request."""
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    """Schema for password reset."""
    token: str
    new_password: str = Field(..., min_length=8, max_length=128)


class UserProfileResponse(BaseModel):
    """Schema for returning user profile."""
    id: str
    name: Optional[str] = None
    email: str
    is_verified: bool
    language: str

    class Config:
        from_attributes = True


class MessageResponse(BaseModel):
    """Generic message response."""
    message: str
