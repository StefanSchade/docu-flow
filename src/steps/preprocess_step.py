import os
import cv2
import json
import datetime
from ..pipeline.pipeline_step import PipelineStep


class PreprocessStep(PipelineStep):

    def __init__(self, parameters):
        self.grayscale =            getattr(parameters, "grayscale",            False)  # noqa: 501
        self.remove_noise =         getattr(parameters, "remove_noise",         False)  # noqa: 501
        self.threshold =            getattr(parameters, "threshold",            False)  # noqa: 501
        self.adaptive_threshold =   getattr(parameters, "adaptive_threshold",   False)  # noqa: 501
        self.block_size =           getattr(parameters, "block_size",           3)      # noqa: 501
        self.noise_constant =       getattr(parameters, "noise_constant",       5)      # noqa: 501
        self.dilate =               getattr(parameters, "dilate",               False)  # noqa: 501
        self.erode =                getattr(parameters, "erode",                False)  # noqa: 501
        self.invert =               getattr(parameters, "invert",               False)  # noqa: 501

    @staticmethod
    def set_arguments(parser):
        parser.add_argument('--grayscale',          type=bool, default=None, help='Convert image to grayscale')                 # noqa: E501
        parser.add_argument('--remove-noise',       type=bool, default=None, help='Apply noise removal')                        # noqa: E501
        parser.add_argument('--threshold',          type=bool, default=None, help='Apply threshold binarization')               # noqa: E501
        parser.add_argument('--adaptive-threshold', type=bool, default=None, help='Use adaptive thresholding')                  # noqa: E501
        parser.add_argument('--block-size',         type=int,  default=None, help='Block size for adaptive thresholding')       # noqa: E501
        parser.add_argument('--noise-constant',     type=int,  default=None, help='Noise constant for adaptive thresholding')   # noqa: E501
        parser.add_argument('--dilate',             type=bool, default=None, help='Apply dilation')                             # noqa: E501
        parser.add_argument('--erode',              type=bool, default=None, help='Apply erosion')                              # noqa: E501
        parser.add_argument('--invert',             type=bool, default=None, help='Invert the image colors')                    # noqa: E501

    def get_total_items(self, input_data):
        """Return the number of image files to be processed."""
        image_files = [f for f in os.listdir(input_data) if f.endswith((".png", ".jpg", ".jpeg"))]
        return len(image_files)

    def run(self, input_data, progress_bar=None):
        """Run the preprocessing on all image files in the input_data directory."""
        # print(f"Preprocessing data in {input_data}")
        
        metadata = self._initialize_metadata()

        preprocessed_dir = self._create_output_directory(input_data)

        # Process all images in the input directory
        processed_any = self._process_images(input_data, preprocessed_dir, metadata, progress_bar)

        # Mark the end time and finalize metadata
        self._finalize_metadata(metadata, processed_any)
        self._save_metadata(metadata, preprocessed_dir)

        if progress_bar:
            progress_bar.close()

        print(f"Preprocessing complete. Metadata saved in {preprocessed_dir}/metadata.json")
        return True

    def _initialize_metadata(self):
        """Initialize the metadata dictionary for this preprocessing step."""
        return {
            "start_time": str(datetime.datetime.now()),
            "num_images_processed": 0,
            "parameters": {
                "grayscale": self.grayscale,
                "remove_noise": self.remove_noise,
                "threshold": self.threshold,
                "adaptive_threshold": self.adaptive_threshold,
                "block_size": self.block_size,
                "noise_constant": self.noise_constant,
                "dilate": self.dilate,
                "erode": self.erode,
                "invert": self.invert,
            },
            "processed_files": []
        }

    def _create_output_directory(self, input_data):
        """Create a directory for preprocessed images."""
        preprocessed_dir = os.path.join(input_data, 'preprocessed')
        if not os.path.exists(preprocessed_dir):
            os.makedirs(preprocessed_dir)
        return preprocessed_dir

    def _process_images(self, input_data, preprocessed_dir, metadata, progress_bar):
        """Process each image in the input_data directory."""
        processed_any = False
        image_files = [f for f in os.listdir(input_data) if f.endswith((".png", ".jpg", ".jpeg"))]
        
        for file_name in image_files:
            file_path = os.path.join(input_data, file_name)
            # print(f"Processing file: {file_name}")
            
            img = self._load_image(file_path)
            img = self._apply_preprocessing(img)
            
            output_file_path = os.path.join(preprocessed_dir, file_name)
            cv2.imwrite(output_file_path, img)
            
            metadata["num_images_processed"] += 1
            metadata["processed_files"].append(file_name)
            processed_any = True

            if progress_bar:
                progress_bar.update(1)
        
        return processed_any

    def _load_image(self, file_path):
        """Load the image using OpenCV."""
        return cv2.imread(file_path, cv2.IMREAD_COLOR)

    def _apply_preprocessing(self, img):
        """Apply the preprocessing steps to the image."""
        if self.grayscale:
            img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        if self.remove_noise:
            img = cv2.medianBlur(img, 5)
        if self.threshold:
            _, img = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
        if self.adaptive_threshold:
            img = cv2.adaptiveThreshold(
                img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                cv2.THRESH_BINARY, self.block_size,
                self.noise_constant
            )
        if self.dilate:
            kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
            img = cv2.dilate(img, kernel, iterations=1)
        if self.erode:
            kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
            img = cv2.erode(img, kernel, iterations=1)
        if self.invert:
            img = cv2.bitwise_not(img)
        return img

    def _finalize_metadata(self, metadata, processed_any):
        """Finalize the metadata at the end of the process."""
        metadata["end_time"] = str(datetime.datetime.now())
        metadata["status"] = "completed" if processed_any else "no images processed"

    def _save_metadata(self, metadata, preprocessed_dir):
        """Save the metadata to a JSON file."""
        metadata_file_path = os.path.join(preprocessed_dir, 'metadata.json')
        with open(metadata_file_path, 'w') as f:
            json.dump(metadata, f, indent=4)

