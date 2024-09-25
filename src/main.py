import json
import argparse
from argparse import Namespace
from .pipeline.pipeline_manager import PipelineManager
from .steps.preprocess_step import PreprocessStep


def load_document_type_defaults(document_type_file, document_type):
    with open(document_type_file, "r") as file:
        document_type_defaults = json.load(file)
    return document_type_defaults.get(document_type, {})


def merge_parameters(json_params, args):
    """Merge the parameters from the JSON file with command-line arguments."""
    params = {}
    params.update(json_params)  # Load defaults from JSON
    for key, value in vars(args).items():
        if value is not None:
            params[key] = value
    return params


def main():
    parser = argparse.ArgumentParser(description="Run OCR pipeline")

    # in the production setup or when simply running the code in dev mode
    # the defaults are used - these values are not intended to be changed
    # by the user and are not documented - they are externalized for
    # integration testing

    parser.add_argument(
        "--data-dir",
        type=str,
        default="/data",  # default mount point for both in- and output data
        help=argparse.SUPPRESS,  # hide from help output
    )

    parser.add_argument(
        "--config",
        type=str,
        # default pipeline def.
        default="/workspace/src/configs/pipeline_config.json",
        help=argparse.SUPPRESS,  # hide from help output
    )

    parser.add_argument(
        "--document_type_defaults",
        type=str,
        default="/workspace/src/configs/document_type_defaults.json",  # sets of defaults
        help=argparse.SUPPRESS,  # hide from help output
    )

    # user pointing arguments

    parser.add_argument(
        "--document_type",
        type=str,
        default=None,
        help="acitivate a document type dependent set of defaults"
        "(possible values: book_photos, ebook_screencaptured)",
    )

    parser.add_argument(
        "--start-step",
        type=str,
        default=None,
        help="Step to start the pipeline from",
    )

    parser.add_argument(
        "--end-step",
        type=str,
        default=None,
        help="Step to end the pipeline at",
    )

    # PreprocessStep specific arguments (these are overrides)
    PreprocessStep.set_arguments(parser)

    args = parser.parse_args()

    # Load the document type defaults from the new JSON file
    document_type_defaults = load_document_type_defaults(
        args.document_type_defaults, args.document_type
    )

    # Merge JSON parameters with command-line overrides
    step_parameters_dict = merge_parameters(document_type_defaults, args)
    step_parameters = Namespace(**step_parameters_dict)

    try:
        # Initialize the pipeline manager
        pipeline_manager = PipelineManager(
            config_file=args.config, data_dir=args.data_dir
        )

        # Run the pipeline (passing merged parameters to the steps)
        pipeline_manager.run_pipeline(
            start_step=args.start_step,
            end_step=args.end_step,
            step_params=step_parameters,
        )

    except Exception as e:
        print(f"An error occurred during pipeline execution: {str(e)}")
        raise  # Optionally re-raise the error if you want to propagate it


if __name__ == "__main__":
    main()
