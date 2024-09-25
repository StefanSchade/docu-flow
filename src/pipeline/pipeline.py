import importlib


def create_step(step_name, args):
    """Dynamically instantiate step based on pipeline config."""
    # Assume the step class name is the same as the step name
    try:
        # dynamic import of python module based on name in pipeline_config.json
        module = importlib.import_module(
            f"src.steps.{step_name.lower()}_step"
        )
        # retrieve class from the module and instentiate it using args
        step_class = getattr(module, f"{step_name}Step")
        return step_class(args)
    except (ModuleNotFoundError, AttributeError) as e:
        raise ValueError(f"Step {step_name} not recognized: {e}")
