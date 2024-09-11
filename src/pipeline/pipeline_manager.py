import json
import os

from .pipeline import create_step


class PipelineManager:
    def __init__(self, config_file, data_dir):
        self.data_dir = data_dir
        self.load_pipeline_definition(config_file)

    def load_pipeline_definition(self, config_file):
        with open(config_file, 'r') as file:
            self.pipeline_definition = json.load(file)

    def check_dependencies(self, step_name):
        for step in self.pipeline_definition["pipeline"]:
            if step["name"] == step_name:
                for dependency in step["dependencies"]:
                    dep_outputs = self.get_step_outputs(dependency)
                    if not self.verify_outputs(dep_outputs):
                        raise Exception(f"Dependency {dependency} has "
                                        "missing or corrupted output.")
                return True
        return False

    def get_step_outputs(self, step_name):
        for step in self.pipeline_definition["pipeline"]:
            if step["name"] == step_name:
                return [
                    os.path.join(self.data_dir, output)
                    for output in step["outputs"]
                ]
        return []

    def verify_outputs(self, output_paths):
        for output in output_paths:
            if not os.path.exists(output):
                print(f"Output {output} is missing.")

                return False
            if os.path.getsize(output) == 0:
                print(f"Output {output} is empty or corrupted.")
                return False
        return True

    def run_pipeline(self, start_step=None, end_step=None):

        steps = [step["name"] for step in self.pipeline_definition["pipeline"]]
        start_index = steps.index(start_step) if start_step else 0
        end_index = steps.index(end_step) + 1 if end_step else len(steps)

        for step_name in steps[start_index:end_index]:
            if self.check_dependencies(step_name):
                print(f"Running step: {step_name}")
                step_instance = create_step(step_name, self.config)
                step_instance.run(self.data_dir)
                print(f"Step {step_name} completed.")
