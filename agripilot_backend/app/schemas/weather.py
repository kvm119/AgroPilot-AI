from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Optional

class HourlyForecast(BaseModel):
    timestamp: datetime
    temperature: float
    rain_probability: float

class DailyForecast(BaseModel):
    date: datetime
    temp_max: float
    temp_min: float
    rain_summary: str

class AgriculturalWeather(BaseModel):
    temperature: float = Field(..., example=32.5)
    humidity: float = Field(..., example=68.0)
    wind_speed: float = Field(..., example=12.4)
    wind_direction: str = Field(..., example="NE")
    pressure: float = Field(..., example=1012.0)
    rain_probability: float = Field(..., example=40.0)
    uv_index: float = Field(..., example=8.0)
    visibility: float = Field(..., example=10000.0)
    sunrise: str = Field(..., example="06:12 AM")
    sunset: str = Field(..., example="06:45 PM")
    
    # Agricultural Logic
    soil_recommendation: str = Field(..., example="Optimal for seeding")
    irrigation_recommendation: str = Field(..., example="Delay 48 hours")
    spraying_recommendation: str = Field(..., example="High wind risk")

class WeatherResponse(BaseModel):
    """
    Combined response for the Flutter dashboard and AI Orchestrator.
    Contains both raw meteorological data and synthesized agricultural advice.
    """
    location: str = Field(..., example="Vijayawada, Andhra Pradesh")
    current: AgriculturalWeather
    hourly: List[HourlyForecast] = []
    daily: List[DailyForecast] = []
    forecast_summary: str = Field(..., example="Partly cloudy with a chance of light evening showers.")
    last_updated: datetime
    is_fallback: bool = Field(default=False)
    
    # For backward compatibility with older Flutter dashboard fields
    @property
    def temperature(self): return self.current.temperature
    @property
    def humidity(self): return self.current.humidity
    @property
    def rain_probability(self): return self.current.rain_probability
    @property
    def wind_speed(self): return self.current.wind_speed
    @property
    def uv_index(self): return self.current.uv_index
