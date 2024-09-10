import pytest
from src.steps.preprocess_step import PreprocessStep


@pytest.fixture
def preprocess_step():
    return PreprocessStep()


def test_preprocess_step_run(preprocess_step, tmpdir):
    input_dir = tmpdir.mkdir("input")
    assert preprocess_step.run(str(input_dir))
