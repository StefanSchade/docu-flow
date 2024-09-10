import pytest
import os

from src.steps.preprocess_step import PreprocessStep
from argparse import Namespace

@pytest.fixture
def preprocess_step():
    # Create mock args, replicating the structure of command-line arguments
    mock_args = Namespace(grayscale=True, remove_noise=True, threshold=False, adaptive_threshold=False, 
                          block_size=3, noise_constant=5, dilate=False, erode=False, invert=False)
    
    return PreprocessStep(mock_args)

def test_preprocess_step_run(preprocess_step, tmpdir):
    input_dir = tmpdir.mkdir("input")
    result = preprocess_step.run(str(input_dir))
    
    # Verify that the 'preprocessed' directory was created
    preprocessed_dir = os.path.join(str(input_dir), 'preprocessed')
    assert os.path.exists(preprocessed_dir)
    
    # Verify that the dummy preprocessed file was created
    dummy_file = os.path.join(preprocessed_dir, 'dummy_preprocessed.txt')
    assert os.path.exists(dummy_file)
    assert result == True
