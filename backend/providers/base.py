from abc import ABC, abstractmethod


class BaseProvider(ABC):
    @abstractmethod
    def fetch_option_chain(self, ticker: str) -> dict:
        pass


def get_provider(provider_name: str) -> BaseProvider:
    if provider_name.lower() == "polygon":
        from .polygon_adapter import PolygonAdapter

        return PolygonAdapter()
    from .yfinance_adapter import YFinanceAdapter

    return YFinanceAdapter()
