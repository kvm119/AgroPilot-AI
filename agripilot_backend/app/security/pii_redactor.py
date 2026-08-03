import re
from typing import Dict, Any

class PIIRedactor:
    """
    Strips sensitive information from logs and analytics payloads before persistence.
    """
    
    # Simple regex for 12 digit Aadhaar
    AADHAAR_REGEX = re.compile(r'\b\d{4}\s?\d{4}\s?\d{4}\b')
    # Simple regex for Indian phone numbers
    PHONE_REGEX = re.compile(r'\b(?:\+91[-.\s]?)?[6789]\d{9}\b')
    
    @classmethod
    def redact_text(cls, text: str) -> str:
        if not text:
            return text
            
        redacted = cls.AADHAAR_REGEX.sub("[REDACTED_AADHAAR]", text)
        redacted = cls.PHONE_REGEX.sub("[REDACTED_PHONE]", redacted)
        return redacted

    @classmethod
    def redact_dict(cls, data: Dict[str, Any]) -> Dict[str, Any]:
        redacted = {}
        for k, v in data.items():
            if isinstance(v, str):
                redacted[k] = cls.redact_text(v)
            elif isinstance(v, dict):
                redacted[k] = cls.redact_dict(v)
            else:
                redacted[k] = v
        return redacted
