import argparse
from pipeline.pipeline_manager import PipelineManager


def main():
    parser = argparse.ArgumentParser(description='Run OCR pipeline')
    parser.add_argument('--config', type=str, default='src/configs/pipeline_config.json', help='Path to pipeline config file')   # noqa: E501
    parser.add_argument('--start-step', type=str, default=None, help='Step to start the pipeline from')  # noqa: E501
    parser.add_argument('--end-step', type=str, default=None, help='Step to end the pipeline at')  # noqa: E501
    parser.add_argument('--data-dir', type=str, default='/workspace/data', help='Directory containing input data')  # noqa: E501

    args = parser.parse_args()

    # Initialize the Pipeline Manager with the config and data directory
    pipeline_manager = PipelineManager(config_file=args.config,
                                       data_dir=args.data_dir)

    # Run the pipeline from the specified start to end step
    try:
        pipeline_manager.run_pipeline(start_step=args.start_step,
                                      end_step=args.end_step)
    except Exception as e:
        print(f"Pipeline execution failed: {e}")


if __name__ == "__main__":
    main()
