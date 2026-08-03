from abc import ABC, abstractmethod
from typing import List
from ....schemas.government import RawGovernmentScheme

class GovernmentProvider(ABC):
    """
    Abstract interface for fetching raw government scheme data.
    """
    
    @abstractmethod
    async def fetch_schemes(self) -> List[RawGovernmentScheme]:
        pass

    @abstractmethod
    async def fetch_subsidies(self) -> List[RawGovernmentScheme]:
        pass

    @abstractmethod
    async def fetch_loans_and_insurance(self) -> List[RawGovernmentScheme]:
        pass
