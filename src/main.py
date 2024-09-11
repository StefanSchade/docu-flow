import json
import argparse
from pipeline.pipeline_manager import PipelineManager
from steps.preprocess_step import PreprocessStep


def load_document_type_defaults(document_type_file, document_type):
    with open(document_type_file, 'r') as file:
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
    parser = argparse.ArgumentParser(description='Run OCR pipeline')
    parser.add_argument(
        '--config',
        type=str,
        default='src/configs/pipeline_config.json',
        help='Path to pipeline config file'
    )
    parser.add_argument(
        '--document_type_defaults',
        type=str,
        default='src/configs/document_type_defaults.json',
        help='Path to document type defaults file'
    )
    parser.add_argument(
        '--document_type',
        type=str,
        default='book_photos',
        help='Type of document (e.g., book_photos, ebook_screencaptured)'
    )
    parser.add_argument(
        '--start-step',
        type=str,
        default=None,
        help='Step to start the pipeline from'
    )
    parser.add_argument(
        '--end-step',
        type=str,
        default=None,
        help='Step to end the pipeline at'
    )

    # PreprocessStep specific arguments (these are overrides)
    PreprocessStep.set_arguments(parser)

    args = parser.parse_args()

    # Load the document type defaults from the new JSON file
    document_type_defaults = load_document_type_defaults(
            args.document_type_defaults,
            args.document_type
    )

    # Merge JSON parameters with command-line overrides
    step_parameters = merge_parameters(document_type_defaults, args)

    try:
        # Initialize the pipeline manager
        pipeline_manager = PipelineManager(
                config_file=args.config,
                data_dir='/workspace/data'
        )

        # Run the pipeline (passing merged parameters to the steps)
        pipeline_manager.run_pipeline(
            start_step=args.start_step,
            end_step=args.end_step,
            step_parameters=step_parameters
        )

    except Exception as e:
        print(f"An error occurred during pipeline execution: {str(e)}")
        raise  # Optionally re-raise the error if you want to propagate it


if __name__ == "__main__":
    main()
