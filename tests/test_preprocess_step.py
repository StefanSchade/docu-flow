import pytest
import os
import cv2
import numpy as np
from src.steps.preprocess_step import PreprocessStep
from argparse import Namespace


@pytest.fixture
def preprocess_step():
    # Create mock args, replicating the structure of command-line arguments
    mock_args = Namespace(
        grayscale=True,
        remove_noise=True,
        threshold=False,
        adaptive_threshold=False,
        block_size=3,
        noise_constant=5,
        dilate=False,
        erode=False,
        invert=False,
    )
    return PreprocessStep(mock_args)


def test_preprocess_step_run(preprocess_step, tmpdir):
    # Create the input directory
    input_dir = tmpdir.mkdir("input")

    # Create a dummy image to be processed
    dummy_image_path = os.path.join(str(input_dir), "dummy_image.jpg")
    dummy_image = 255 * np.ones((100, 100, 3), dtype=np.uint8)  # white square
    cv2.imwrite(dummy_image_path, dummy_image)  # Save the dummy image

    # Run the preprocess step
    result = preprocess_step.run(str(input_dir))

    # Verify that the 'preprocessed' directory was created
    preprocessed_dir = os.path.join(str(input_dir), "preprocessed")
    assert os.path.exists(preprocessed_dir)

    # Verify that the metadata file was created
    metadata_file = os.path.join(preprocessed_dir, "metadata.json")
    assert os.path.exists(metadata_file)

    # Verify that the process completed successfully
    assert result
