import pytest
from src.steps.preprocess_step import PreprocessStep
import os


@pytest.fixture
def preprocess_step():
    return PreprocessStep()


def test_preprocess_step_run(preprocess_step, tmpdir):
    input_dir = tmpdir.mkdir("input")
    result = preprocess_step.run(str(input_dir))

    # Verify that the 'preprocessed' directory was created
    preprocessed_dir = os.path.join(str(input_dir),
                                    'preprocessed')
    assert os.path.exists(preprocessed_dir)

    # Verify that the dummy preprocessed file was created
    dummy_file = os.path.join(preprocessed_dir,
                              'dummy_preprocessed.txt')
    assert os.path.exists(dummy_file)
    assert result
