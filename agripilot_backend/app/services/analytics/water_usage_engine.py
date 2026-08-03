class WaterUsageEngine:
    def analyze_water_usage(self, applied_irrigation_mm: float, rainfall_mm: float, crop_demand_mm: float) -> str:
        total_water = applied_irrigation_mm + rainfall_mm
        
        if total_water > crop_demand_mm * 1.15:
            return "OVER_WATERED"
        elif total_water < crop_demand_mm * 0.85:
            return "UNDER_WATERED"
        return "OPTIMAL"
