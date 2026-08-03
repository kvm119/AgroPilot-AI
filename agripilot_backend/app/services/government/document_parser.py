import re
from typing import List
from ...schemas.government import RawGovernmentScheme

class DocumentParser:
    """
    Extracts required document names using string parsing and Regex.
    """
    
    def extract_required_documents(self, scheme: RawGovernmentScheme) -> List[str]:
        raw = scheme.documents_raw_text
        if not raw:
            return []
            
        # Split by comma or bullet points and clean up
        docs = []
        tokens = re.split(r',|\n', raw)
        for token in tokens:
            token = token.strip()
            if token:
                docs.append(token)
                
        return docs
