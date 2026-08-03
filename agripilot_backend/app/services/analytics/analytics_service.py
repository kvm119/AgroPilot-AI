import logging
from .analytics_repository import AnalyticsRepository
from .yield_engine import YieldEngine
from .water_usage_engine import WaterUsageEngine
from .profitability_engine import ProfitabilityEngine
from .trend_engine import TrendEngine
from .prediction_engine import PredictionEngine
from .recommendation_engine import RecommendationEngine
from .report_generator import ReportGenerator
from .models.analytics_models import AnalyticsReport

logger = logging.getLogger(__name__)

class AnalyticsService:
    def __init__(self):
        self.repository = AnalyticsRepository()
        self.yield_engine = YieldEngine()
        self.water_engine = WaterUsageEngine()
        self.profit_engine = ProfitabilityEngine()
        self.trend_engine = TrendEngine()
        self.prediction_engine = PredictionEngine()
        self.recommendation_engine = RecommendationEngine()
        self.report_generator = ReportGenerator()

    async def get_farm_analytics_report(self, farm_id: str, season: str = "current") -> AnalyticsReport:
        logger.info(f"Generating analytics report for farm {farm_id}")
        
        # 1. Fetch raw data
        costs = await self.repository.fetch_historical_costs(farm_id, season)
        revenue = await self.repository.fetch_historical_revenue(farm_id, season)
        yield_history = await self.repository.fetch_yield_history(farm_id)
        water_used = await self.repository.fetch_water_usage(farm_id, season)
        lifecycle = await self.repository.fetch_crop_lifecycle_events(farm_id, season)
        
        # 2. Run Engines (Deterministic Math)
        profitability = self.profit_engine.calculate(costs, revenue)
        
        yield_metrics = self.yield_engine.calculate_yield_metrics(yield_history)
        yield_trend = self.trend_engine.calculate_yield_trend(yield_metrics)
        
        water_status = self.water_engine.analyze_water_usage(water_used, 50.0, 480.0) # Mock rainfall and demand
        
        harvest_prediction = self.prediction_engine.predict_harvest_date(lifecycle)
        
        # 3. Generate Recommendations based on calculated metrics
        recommendations = self.recommendation_engine.generate_recommendations(
            profitability=profitability,
            yield_trend=yield_trend,
            water_status=water_status,
            predictions=[harvest_prediction]
        )
        
        # 4. Construct Final Report Model
        report = AnalyticsReport(
            farm_id=farm_id,
            season=season,
            profitability=profitability,
            trends=[yield_trend],
            predictions=[harvest_prediction],
            recommendations=recommendations
        )
        
        return report

def get_analytics_service() -> AnalyticsService:
    return AnalyticsService()
