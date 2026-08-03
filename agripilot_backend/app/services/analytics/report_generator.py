from typing import List
from .models.analytics_models import AnalyticsReport, Profitability, Trend, Prediction, AnalyticsRecommendation

class ReportGenerator:
    def generate_dashboard_json(self, report: AnalyticsReport) -> dict:
        return report.model_dump()
        
    def generate_copilot_summary(self, report: AnalyticsReport) -> str:
        """
        Formats the metrics into a clear text summary for the AI Orchestrator to inject into the LLM context.
        """
        summary = f"Analytics Report for Farm {report.farm_id} (Season: {report.season})\n"
        summary += "-"*40 + "\n"
        summary += f"Profitability: ROI = {report.profitability.roi_percentage}%, Profit = Rs {report.profitability.profit}\n"
        summary += f"Government Subsidies Saved: Rs {report.profitability.government_savings}\n"
        
        for t in report.trends:
            summary += f"Trend: {t.metric_name} is trending {t.direction} (Change: {t.percentage_change}%)\n"
            
        for p in report.predictions:
            summary += f"Prediction: {p.target} -> {p.predicted_value} (Confidence: {p.confidence})\n"
            
        for r in report.recommendations:
            summary += f"AI Recommendation [{r.priority}]: {r.action} - {r.rationale}\n"
            
        return summary
