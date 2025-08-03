import json
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List

from backend.schemas import StrategyMetadata, ScanRequest, ScanResponse, Opportunity
from backend.strategies.base import load_strategy_plugin
from backend.providers.base import get_provider
from backend.utils.firestore import get_firestore_client

app = FastAPI(
    title="Options Scanner API",
    version="0.1.0",
    description="Backend service for scanning options strategies",
)
# allow CORS for all origins (adjust in production)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# directory where strategy JSON configs are stored
CONFIG_DIR = Path(__file__).parents[1] / "config" / "strategies"


@app.get("/api/strategies", response_model=List[StrategyMetadata])
async def list_strategies():
    """
    Return metadata for all available strategies.
    """
    strategies = []
    for path in CONFIG_DIR.glob("*.json"):
        data = json.loads(path.read_text())
        strategies.append(StrategyMetadata(**data))
    return strategies


@app.post("/api/scan", response_model=ScanResponse)
async def run_scan(request: ScanRequest):
    """
    Trigger a scan for the specified strategy over given tickers.
    """
    try:
        plugin = load_strategy_plugin(request.strategy_id)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
    provider = get_provider(request.provider)
    opportunities = []
    for ticker in request.tickers:
        chain = provider.fetch_option_chain(ticker)
        results = plugin.run_scan(chain, request.params)
        for item in results:
            opportunities.append(
                Opportunity(ticker=ticker, strategy=request.strategy_id, **item)
            )
    # persist latest results in Firestore
    db = get_firestore_client()
    db.collection("results").document(request.strategy_id).set(
        {"opportunities": [op.dict() for op in opportunities]}
    )
    return ScanResponse(opportunities=opportunities)


@app.post("/api/save-config")
async def save_config(config: dict):
    """
    Save user-modified strategy configuration to Firestore.
    """
    strategy_id = config.get("id")
    if not strategy_id:
        raise HTTPException(status_code=400, detail="Missing strategy id")
    db = get_firestore_client()
    db.collection("strategies").document(strategy_id).set(config)
    return {"status": "ok"}


@app.get("/api/results/{strategy_id}")
async def get_results(strategy_id: str):
    """
    Retrieve the most recent scan results for a strategy from Firestore.
    """
    db = get_firestore_client()
    doc = db.collection("results").document(strategy_id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="No results for this strategy")
    return doc.to_dict()
