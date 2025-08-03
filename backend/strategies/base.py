import json
import importlib
from pathlib import Path


class BaseStrategyPlugin:
    """
    Base class for all strategy plugins.
    """
    def __init__(self, config: dict):
        self.config = config

    def run_scan(self, option_chain: dict, params: dict) -> list:
        """
        Execute a scan on the option_chain using params.
        Should return a list of opportunity dicts.
        """
        raise NotImplementedError


def load_strategy_plugin(strategy_id: str) -> BaseStrategyPlugin:
    """
    Load a strategy plugin by its identifier and configuration JSON.
    """
    root = Path(__file__).parents[2]
    config_path = root / "config" / "strategies" / f"{strategy_id}.json"
    if not config_path.exists():
        raise ValueError(f"Strategy config not found: {strategy_id}")
    config = json.loads(config_path.read_text())
    module_name = f"backend.strategies.{strategy_id}"
    try:
        module = importlib.import_module(module_name)
        plugin_cls = getattr(module, "StrategyPlugin")
    except (ModuleNotFoundError, AttributeError) as e:
        raise ImportError(f"Plugin class not found for strategy {strategy_id}: {e}")
    return plugin_cls(config)
