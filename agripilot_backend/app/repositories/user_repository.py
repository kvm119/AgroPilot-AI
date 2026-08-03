"""
User repository — database abstraction layer for User model.
All direct DB access for user operations goes through here.
"""
from typing import Optional
from sqlalchemy.orm import Session
from ..models.user import User


def create_user(db: Session, name: str, email: str, password_hash: str) -> User:
    """Create a new user record in the database."""
    user = User(
        name=name,
        email=email,
        password_hash=password_hash,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def get_user_by_email(db: Session, email: str) -> Optional[User]:
    """Look up a user by their email address."""
    return db.query(User).filter(User.email == email).first()


def get_user_by_id(db: Session, user_id: str) -> Optional[User]:
    """Look up a user by their UUID."""
    return db.query(User).filter(User.id == user_id).first()


def update_password(db: Session, user: User, new_password_hash: str) -> User:
    """Update a user's password hash."""
    user.password_hash = new_password_hash
    db.commit()
    db.refresh(user)
    return user
