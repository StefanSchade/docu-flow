import pytest
from src.steps.ocr_step import OCRStep


@pytest.fixture
def ocr_step():
    parameters = {}
    return OCRStep(parameters)


# verify that an OCRStep can run sucessfully
def test_ocr_step_run(ocr_step, tmpdir):
    input_dir = tmpdir.mkdir("input")
    assert ocr_step.run(str(input_dir))
