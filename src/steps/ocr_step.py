from pipeline.pipeline_step import PipelineStep


class OCRStep(PipelineStep):
    def run(self, input_data):
        print(f"Performing OCR on data in {input_data}")
        # Placeholder for OCR logic
        return True

    @staticmethod
    def set_arguments(parser):
        # placeholder for implementation
        pass
