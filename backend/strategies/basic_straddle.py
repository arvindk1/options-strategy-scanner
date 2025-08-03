from .base import BaseStrategyPlugin


class StrategyPlugin(BaseStrategyPlugin):
    """
    Basic straddle strategy: buy call and put at the same strike to profit from volatility.
    """
    id = "basic_straddle"
    name = "Basic Straddle"

    def run_scan(self, option_chain: dict, params: dict) -> list:
        # stub implementation: no-op scan
        return []
