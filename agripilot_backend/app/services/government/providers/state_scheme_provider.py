import asyncio
import logging
from typing import List
from .base_provider import GovernmentProvider
from ....schemas.government import RawGovernmentScheme

logger = logging.getLogger(__name__)

class StateSchemeProvider(GovernmentProvider):
    async def fetch_schemes(self) -> List[RawGovernmentScheme]:
        logger.info("Fetching State Scheme data")
        await asyncio.sleep(0.2)
        return [
            RawGovernmentScheme(
                id="ap-rythu-01",
                name="YSR Rythu Bharosa",
                description="Financial assistance to farmers in AP.",
                provider="Andhra Pradesh State Government",
                state_restriction="Andhra Pradesh",
                benefits_raw_text="Rs. 13,500 per year including PM-Kisan.",
                documents_raw_text="Aadhaar, Pattadar Passbook.",
                url="https://ysrrythubharosa.ap.gov.in"
            ),
            RawGovernmentScheme(
                id="ts-rythu-01",
                name="Rythu Bandhu",
                description="Investment support scheme.",
                provider="Telangana State Government",
                state_restriction="Telangana",
                benefits_raw_text="Rs. 5,000 per acre per season.",
                documents_raw_text="Aadhaar, Land records.",
            )
        ]

    async def fetch_subsidies(self) -> List[RawGovernmentScheme]:
        return []

    async def fetch_loans_and_insurance(self) -> List[RawGovernmentScheme]:
        return []
