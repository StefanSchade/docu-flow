import os
from pipeline.pipeline_step import PipelineStep


class PreprocessStep(PipelineStep):
    def run(self, input_data):
        print(f"Preprocessing data in {input_data}")

        # Example: Create a 'preprocessed' dir and simulate image processing
        preprocessed_dir = os.path.join(input_data,
                                        'preprocessed')
        if not os.path.exists(preprocessed_dir):
            os.makedirs(preprocessed_dir)

        # Simulate preprocessing by creating a dummy processed file
        dummy_file_path = os.path.join(preprocessed_dir,
                                       'dummy_preprocessed.txt')
        with open(dummy_file_path, 'w') as f:
            f.write("Preprocessed data")

        print(f"Preprocessing complete. Output saved in {preprocessed_dir}")
        return True
