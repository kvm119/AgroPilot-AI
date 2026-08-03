import logging
from typing import Dict, Any

from ...schemas.government import GovernmentInsights
from ...repositories.government_repository import GovernmentRepository
from .eligibility_engine import EligibilityEngine
from .recommendation_engine import RecommendationEngine

logger = logging.getLogger(__name__)

class GovernmentService:
    """
    The orchestrator for all government scheme intelligence.
    """
    def __init__(self):
        self.repository = GovernmentRepository()
        self.eligibility = EligibilityEngine()
        self.recommender = RecommendationEngine()

    async def fetch_eligible_schemes(self, user_context: Dict[str, Any]) -> GovernmentInsights:
        # 1. Fetch raw data from repositories
        all_schemes = await self.repository.get_all_schemes()
        all_subsidies = await self.repository.get_all_subsidies()
        all_loans = await self.repository.get_all_loans()
        
        is_fallback = not all_schemes and not all_subsidies and not all_loans
        
        # 2. Filter by Eligibility
        eligible_schemes = self.eligibility.filter_by_eligibility(all_schemes, user_context)
        eligible_subsidies = self.eligibility.filter_by_eligibility(all_subsidies, user_context)
        eligible_loans = self.eligibility.filter_by_eligibility(all_loans, user_context)
        
        # 3. Build Actionable JSON
        scheme_recs = self.recommender.build_actionable_recommendations(eligible_schemes, user_context)
        subsidy_recs = self.recommender.build_actionable_recommendations(eligible_subsidies, user_context)
        loan_recs = self.recommender.build_actionable_recommendations(eligible_loans, user_context)
        
        return GovernmentInsights(
            schemes=scheme_recs,
            subsidies=subsidy_recs,
            loans_and_insurance=loan_recs,
            is_fallback=is_fallback
        )

def get_government_service() -> GovernmentService:
    return GovernmentService()
