from .base import BaseProvider


class PolygonAdapter(BaseProvider):
    """
    Adapter for fetching option chains using Polygon.io.
    """
    def fetch_option_chain(self, ticker: str) -> dict:
        raise NotImplementedError("Polygon adapter not implemented yet")
