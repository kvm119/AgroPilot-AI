import hashlib
import json
import uuid
import logging
from datetime import datetime
from typing import Optional
from .models.security_models import AuditLog
from .pii_redactor import PIIRedactor

# Setup isolated logger for audit trail
audit_logger = logging.getLogger("audit_trail")
audit_logger.setLevel(logging.INFO)
# In production, this would write to a specialized WORM (Write Once Read Many) drive or cloud service

class AuditLogger:
    """
    Creates tamper-evident logs for security events.
    """
    _last_hash = "0000000000000000000000000000000000000000000000000000000000000000"
    
    @classmethod
    def log_event(cls, user_id: str, action: str, resource: str, status: str, ip_address: Optional[str] = None):
        
        # Redact potentially sensitive resource info before hashing
        safe_resource = PIIRedactor.redact_text(resource)
        
        timestamp = datetime.now()
        log_id = str(uuid.uuid4())
        
        # Construct the payload to hash
        payload = f"{log_id}|{timestamp.isoformat()}|{user_id}|{action}|{safe_resource}|{status}|{cls._last_hash}"
        current_hash = hashlib.sha256(payload.encode()).hexdigest()
        
        log_entry = AuditLog(
            id=log_id,
            timestamp=timestamp,
            user_id=user_id,
            action=action,
            resource=safe_resource,
            ip_address=ip_address,
            status=status,
            previous_hash=cls._last_hash,
            entry_hash=current_hash
        )
        
        # Update chain
        cls._last_hash = current_hash
        
        # Write to log
        audit_logger.info(json.dumps(log_entry.model_dump(), default=str))
        
        return log_entry
