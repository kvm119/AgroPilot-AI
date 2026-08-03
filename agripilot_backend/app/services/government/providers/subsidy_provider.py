import asyncio
import logging
from typing import List
from .base_provider import GovernmentProvider
from ....schemas.government import RawGovernmentScheme

logger = logging.getLogger(__name__)

class SubsidyProvider(GovernmentProvider):
    async def fetch_schemes(self) -> List[RawGovernmentScheme]:
        return []

    async def fetch_subsidies(self) -> List[RawGovernmentScheme]:
        logger.info("Fetching Subsidy data")
        await asyncio.sleep(0.1)
        return [
            RawGovernmentScheme(
                id="smam-01",
                name="Sub-Mission on Agricultural Mechanization (SMAM)",
                description="Subsidy for purchasing farm machinery.",
                provider="Central Government",
                benefits_raw_text="Up to 80% subsidy on agricultural machinery like tractors.",
                documents_raw_text="Aadhaar, Quotation of Machinery, Bank Passbook, Land Record.",
                url="https://agrimachinery.nic.in"
            ),
            RawGovernmentScheme(
                id="fert-01",
                name="Nutrient Based Subsidy (NBS)",
                description="Fertilizer subsidy.",
                provider="Central Government",
                benefits_raw_text="Subsidized rates for P and K fertilizers.",
                documents_raw_text="Farmer ID, Aadhaar.",
            )
        ]

    async def fetch_loans_and_insurance(self) -> List[RawGovernmentScheme]:
        return []
