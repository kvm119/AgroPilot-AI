import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.database import Base
from app.repositories.memory_repository import MemoryRepository
from app.models.user import User

# In-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    yield db
    db.close()
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def mock_user(db_session):
    user = User(firebase_uid="mock_uid_123", phone_number="+1234567890")
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user

def test_repository_creates_conversation_and_messages(db_session, mock_user):
    repo = MemoryRepository(db_session)
    conv_id = "test_conv_1"
    
    # Create conversation implicitly
    repo.get_or_create_conversation(conv_id, str(mock_user.id))
    
    # Append messages
    repo.append_message(conv_id, "user", "Hello")
    repo.append_message(conv_id, "assistant", "Hi there")
    
    history = repo.load_history(conv_id)
    
    assert len(history) == 2
    assert history[0]["role"] == "user"
    assert history[0]["content"] == "Hello"
    assert history[1]["role"] == "assistant"

def test_repository_limits_history(db_session, mock_user):
    repo = MemoryRepository(db_session)
    conv_id = "test_conv_2"
    repo.get_or_create_conversation(conv_id, str(mock_user.id))
    
    # Add 25 messages
    for i in range(25):
        repo.append_message(conv_id, "user", f"Msg {i}")
        
    # Should only load the last 20 by default
    history = repo.load_history(conv_id, limit=20)
    assert len(history) == 20
    # The last message added was Msg 24, so it should be at the end of chronological order
    assert history[-1]["content"] == "Msg 24"
    assert history[0]["content"] == "Msg 5" # (25 - 20)

def test_entity_persistence(db_session, mock_user):
    repo = MemoryRepository(db_session)
    
    repo.save_entity(str(mock_user.id), "disease", "Yellow Rust", 0.9)
    repo.save_entity(str(mock_user.id), "disease", "Leaf Blight", 0.8)
    repo.save_entity(str(mock_user.id), "crop", "Wheat", 1.0)
    
    diseases = repo.get_entities(str(mock_user.id), "disease")
    assert len(diseases) == 2
    
    all_entities = repo.get_entities(str(mock_user.id))
    assert len(all_entities) == 3
