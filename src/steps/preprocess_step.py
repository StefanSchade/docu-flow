from pipeline.pipeline_step import PipelineStep


class PreprocessStep(PipelineStep):
    def run(self, input_data):
        print(f"Preprocessing data in {input_data}")
        # Placeholder for preprocessing logic
        return True
