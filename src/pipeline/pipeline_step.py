from abc import ABC, abstractmethod


class PipelineStep(ABC):
    @abstractmethod
    def run(self, input_data, progress_bar=None):
        """Runs the step. If progress_bar is provided, report progress."""
        pass

    @staticmethod
    @abstractmethod
    def set_arguments(parser):
        """Method to define step-specific command-line arguments"""
        pass

    def get_total_items(self, input_data=None):
        """
        Optional method for speciffyig the total number of items to process test a very long line and how it is handled by black
        """
        return 100  # Default to 100 (for percentage completion)
