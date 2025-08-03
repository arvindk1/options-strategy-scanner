from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class StrategyMetadata(BaseModel):
    id: str
    name: str
    description: str
    risk_level: Optional[str] = None


class ScanRequest(BaseModel):
    strategy_id: str = Field(..., description="Identifier of the strategy to run")
    tickers: List[str] = Field(..., description="List of ticker symbols to scan")
    params: Dict[str, float] = Field(default_factory=dict, description="Override parameters for the strategy")
    provider: str = Field("yfinance", description="Data provider: yfinance or polygon")


class Opportunity(BaseModel):
    ticker: str
    strategy: str
    score: float
    expected_return: float
    max_risk: float


class ScanResponse(BaseModel):
    opportunities: List[Opportunity]
