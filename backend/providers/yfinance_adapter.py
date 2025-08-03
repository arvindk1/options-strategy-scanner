import yfinance as yf

from .base import BaseProvider


class YFinanceAdapter(BaseProvider):
    """
    Adapter for fetching option chains using yfinance.
    """
    def fetch_option_chain(self, ticker: str) -> dict:
        ticker_obj = yf.Ticker(ticker)
        chains = []
        for expiry in ticker_obj.options or []:
            opt_chain = ticker_obj.option_chain(expiry)
            calls = opt_chain.calls.to_dict(orient="records")
            puts = opt_chain.puts.to_dict(orient="records")
            chains.append({"expiry": expiry, "calls": calls, "puts": puts})
        return {"ticker": ticker, "chains": chains}
