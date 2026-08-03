import asyncio
import logging
from typing import List
from .base_provider import GovernmentProvider
from ....schemas.government import RawGovernmentScheme
from datetime import date

logger = logging.getLogger(__name__)

class PMKisanProvider(GovernmentProvider):
    async def fetch_schemes(self) -> List[RawGovernmentScheme]:
        logger.info("Fetching PM-Kisan data")
        await asyncio.sleep(0.3)
        return [
            RawGovernmentScheme(
                id="pm-kisan-01",
                name="PM-Kisan Samman Nidhi",
                description="Minimum income support for farmers.",
                provider="Central Government",
                max_land_size_acres=5.0, # Generally targeted at small/marginal farmers
                benefits_raw_text="Financial benefit of Rs 6000 per year in three equal installments.",
                documents_raw_text="Aadhaar card, Bank Passbook, Land ownership records.",
                deadline=date(2026, 12, 31),
                url="https://pmkisan.gov.in"
            )
        ]

    async def fetch_subsidies(self) -> List[RawGovernmentScheme]:
        return []

    async def fetch_loans_and_insurance(self) -> List[RawGovernmentScheme]:
        await asyncio.sleep(0.2)
        return [
            RawGovernmentScheme(
                id="pm-fby-01",
                name="Pradhan Mantri Fasal Bima Yojana (PMFBY)",
                description="Crop insurance scheme.",
                provider="Central Government",
                benefits_raw_text="Comprehensive insurance cover against failure of the crop.",
                documents_raw_text="Aadhaar, Sowing Certificate, Bank Account.",
                url="https://pmfby.gov.in"
            )
        ]
