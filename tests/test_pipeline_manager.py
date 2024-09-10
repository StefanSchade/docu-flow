import pytest
from src.pipeline.pipeline_manager import PipelineManager


@pytest.fixture
def pipeline_manager():
    return PipelineManager(
            config_file='/workspace/src/configs/pipeline_config.json',
            data_dir='workspace/test_data')


# Asserts that the Pipelinemanager...


# ...can verify dependencies for a pipeline step
def test_check_dependencies(pipeline_manager):
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
