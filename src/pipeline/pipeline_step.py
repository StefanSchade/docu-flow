from abc import ABC, abstractmethod


class PipelineStep(ABC):
    @abstractmethod
    def run(self, input_data):
        pass

    @staticmethod
    @abstractmethod
    def set_arguments(parser):
        """Method to define step-specific command-line arguments"""
        pass
