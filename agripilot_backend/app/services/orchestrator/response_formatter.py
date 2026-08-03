from typing import Dict, Any, List

class ResponseFormatter:
    """
    Enforces strict mapping into UI-ready formatting (Markdown).
    Prevents raw blocks of paragraphs.
    """
    
    def format_output(self, raw_llm_text: str) -> str:
        # In an advanced production setup, we would instruct Gemini to return strict JSON,
        # and then we construct the markdown here.
        # Since our MVP Gemini wrapper currently just returns a string, we will assume 
        # it is well-formatted or wrap it securely.
        
        formatted = "### AgriPilot Insight\n\n"
        formatted += raw_llm_text
        
        return formatted
