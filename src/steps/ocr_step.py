from ..pipeline.pipeline_step import PipelineStep


class OCRStep(PipelineStep):

    def __init__(self, parameters):
        self.parametrs = parameters

    def run(self, input_data, progress_bar=None):
        print(f"Performing OCR on data in {input_data}")
        # Placeholder for OCR logic
        return True

    @staticmethod
    def set_arguments(parser):
        # placeholder for implementation
        pass
