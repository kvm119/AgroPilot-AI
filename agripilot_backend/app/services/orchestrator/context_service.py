from typing import Dict, Any
from ...repositories.farm_repository import FarmRepository

class ContextService:
    """
    Pulls static user data (Farm Size, Soil Type, Language) via FarmRepository.
    """
    def __init__(self, repo: FarmRepository):
        self.repo = repo
        
    def get_user_context(self, user_id: str) -> Dict[str, Any]:
        farm_data = self.repo.get_farm(user_id)
        
        # If no farm is found, return a default fallback so orchestration doesn't break
        if not farm_data:
            return {
                "farmer_profile": {
                    "name": "Guest Farmer",
                    "preferred_language": "en"
                },
                "farm_details": {
                    "location": "Unknown",
                    "primary_crop": "Unknown",
                    "size_acres": 0.0
                }
            }
            
        return {
            "farmer_profile": {
                "name": "Farmer", # Could be fetched from User table
                "preferred_language": "en"
            },
            "farm_details": farm_data["farm_details"]
        }
