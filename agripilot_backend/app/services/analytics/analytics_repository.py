from typing import Dict, Any, List

class AnalyticsRepository:
    """
    Simulates fetching historical aggregated data from various database tables.
    """
    
    async def fetch_historical_costs(self, farm_id: str, season: str) -> Dict[str, float]:
        # Mocking DB call for historical input costs (seeds, fertilizer, labor)
        return {
            "seed_cost": 500.0,
            "fertilizer_cost": 1200.0,
            "labor_cost": 800.0,
            "government_subsidy_applied": 300.0 # From AGRI-210 schemes
        }

    async def fetch_historical_revenue(self, farm_id: str, season: str) -> float:
        # Mocking DB call for total harvest sales
        return 4500.0

    async def fetch_yield_history(self, farm_id: str) -> List[Dict[str, Any]]:
        # Mocking last 3 years of yield data (tons per acre)
        return [
            {"year": 2023, "yield_tpa": 2.1},
            {"year": 2024, "yield_tpa": 2.3},
            {"year": 2025, "yield_tpa": 2.0} # A slight dip
        ]

    async def fetch_water_usage(self, farm_id: str, season: str) -> float:
        # Mocking total irrigation applied in mm
        return 450.0

    async def fetch_crop_lifecycle_events(self, farm_id: str, season: str) -> Dict[str, Any]:
        return {
            "planting_date": "2026-06-01",
            "seed_variety_days_to_maturity": 120
        }
