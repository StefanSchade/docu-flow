# /workspace/src/monkeytype_config.py

from monkeytype.config import DefaultConfig
from monkeytype import trace
from typing import Any, List
from contextlib import contextmanager

class MyConfig(DefaultConfig):
    # Determines which callables to trace
    def trace_callable(self, target):
        return trace(target)

    # Specifies the desired type coverage percentage
    def type_coverage(self) -> int:
        return 100  # Adjust based on desired coverage percentage

    # Defines actions based on coverage (can be customized)
    def apply_coverage(self, coverage: int) -> None:
        pass

    # Lists files or patterns to exclude from type collection
    def exclude_files(self) -> List[str]:
        return []  # List any files or patterns to exclude

    # Max number of call traces to query, default is 2000 
    def query_limit(self) -> int:
        print("query_limit called")
        return 1000  # Example limit

    # Sampling rate for collecting type information
    def sample_rate(self) -> float:
        print("sample_rate called")
        return 1.0  # 100% sampling rate

    # Context manager for CLI commands
    @contextmanager
    def cli_context(self, command: str):
        print("cli_context called")

        # Setup before command execution (if any)
        yield
        # Teardown after command execution (if any)

# Ensure that MonkeyType uses this configuration
CONFIG = MyConfig()
