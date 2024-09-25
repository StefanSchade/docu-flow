import pytest
from unittest.mock import patch
from src.pipeline.pipeline_manager import PipelineManager


@pytest.fixture
def pipeline_manager():
    mock_pipeline_definition = {
        "pipeline": [
            {
                "name": "PreprocessStep",
                "dependencies": ["DependencyStep1"],
                "outputs": ["output1.png"],
            },
            {
                "name": "DependencyStep1",
                "dependencies": [],
                "outputs": ["dependency_output1.png"],
            },
        ]
    }

    manager = PipelineManager(config_file="", data_dir="/data")
    manager.pipeline_definition = mock_pipeline_definition
    return manager


# Asserts that the Pipelinemanager...


# ...can verify dependencies for a pipeline step
def test_check_dependencies(pipeline_manager):
    # Mock os.path.exists to always return True (to simulate that files exist)
    with (
        patch("os.path.exists", return_value=True),
        patch("os.path.getsize", return_value=100),
    ):  # Assume file is non-empty
        assert pipeline_manager.check_dependencies("PreprocessStep")


# ...can verify that a step has produced the correct output
def test_verify_outputs(pipeline_manager, tmpdir):
    output_dir = tmpdir.mkdir("preprocessed")
    output_file = output_dir.join("dummy_output.txt")
    output_file.write("dummy content")
    assert pipeline_manager.verify_outputs([str(output_file)])


# ...fails to verify a missiong output
def test_missing_output(pipeline_manager):
    assert not pipeline_manager.verify_outputs(["nonexistent_file.txt"])
