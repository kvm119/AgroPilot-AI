from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AuditLog(BaseModel):
    id: str
    timestamp: datetime
    user_id: str
    action: str
    resource: str
    ip_address: Optional[str]
    status: str
    previous_hash: str
    entry_hash: str

class SyncSignature(BaseModel):
    device_id: str
    timestamp: int
    nonce: str
    signature: str
