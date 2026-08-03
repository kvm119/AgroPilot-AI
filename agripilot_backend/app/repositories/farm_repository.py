from sqlalchemy.orm import Session
from typing import Dict, Any, Optional
from ..models.user import Farm

class FarmRepository:
    """
    Abstractions for retrieving static farm data.
    """
    def __init__(self, db: Session):
        self.db = db

    def get_farm(self, user_id: str) -> Optional[Dict[str, Any]]:
        farm = self.db.query(Farm).filter(Farm.user_id == user_id, Farm.is_default == True).first()
        if not farm:
            farm = self.db.query(Farm).filter(Farm.user_id == user_id).first()
        if not farm:
            return None
            
        return {
            "farm_details": {
                "id": farm.id,
                "name": farm.name or "Main Farm Field",
                "survey_number": farm.survey_number or "",
                "village": farm.village or "Guntur Rural",
                "mandal": farm.mandal or "Guntur Mandal",
                "district": farm.district or "Guntur",
                "state": farm.state or "Andhra Pradesh",
                "location": f"Lat: {farm.lat}, Lon: {farm.lon}",
                "latitude": farm.lat,
                "longitude": farm.lon,
                "primary_crop": farm.crop_type,
                "size_acres": farm.size_acres,
                "polygon_json": farm.polygon_json,
                "elevation_meters": farm.elevation_meters or 33.0
            }
        }

    def get_user_farms(self, user_id: str) -> list:
        farms = self.db.query(Farm).filter(Farm.user_id == user_id, Farm.is_archived == False).all()
        return [
            {
                "id": f.id,
                "name": f.name or "Farm Field",
                "crop_type": f.crop_type,
                "size_acres": f.size_acres,
                "lat": f.lat,
                "lon": f.lon,
                "village": f.village,
                "mandal": f.mandal,
                "district": f.district,
                "is_default": f.is_default
            }
            for f in farms
        ]
