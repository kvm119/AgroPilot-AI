from typing import List, Dict, Any
from ...schemas.government import RawGovernmentScheme

class EligibilityEngine:
    """
    Deterministically filters out schemes a farmer does not qualify for.
    Protects the LLM from making incorrect eligibility assumptions.
    """
    
    def filter_by_eligibility(self, schemes: List[RawGovernmentScheme], user_context: Dict[str, Any]) -> List[RawGovernmentScheme]:
        eligible = []
        
        farm_size = user_context.get("farm_size_acres", 10.0)
        state = user_context.get("state", "Unknown")
        
        for scheme in schemes:
            # 1. State Restriction
            if scheme.state_restriction:
                if scheme.state_restriction.lower() != state.lower():
                    continue # Farmer is from a different state
                    
            # 2. Land Size Restriction
            if scheme.max_land_size_acres is not None:
                if farm_size > scheme.max_land_size_acres:
                    continue # Farm is too large
                    
            # If all checks pass, the farmer is eligible
            eligible.append(scheme)
            
        return eligible
