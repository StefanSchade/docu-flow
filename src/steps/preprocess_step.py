import os
import cv2
import json
import datetime
from pipeline.pipeline_step import PipelineStep


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

    def run(self, input_data):
        print(f"Preprocessing data in {input_data}")

        # Metadata dictionary to store information about the step
        metadata = {
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

        # Example: Create a 'preprocessed' dir and simulate image processing
        preprocessed_dir = os.path.join(input_data,
                                        'preprocessed')
        if not os.path.exists(preprocessed_dir):
            os.makedirs(preprocessed_dir)

        # Track if any image files were processed
        processed_any = False

        # List all image files in the input directory
        for file_name in os.listdir(input_data):
            if file_name.endswith((".png", ".jpg", ".jpeg")):
                file_path = os.path.join(input_data, file_name)
                print(f"Processing file: {file_name}")

                # Load the image using OpenCV
                img = cv2.imread(file_path, cv2.IMREAD_COLOR)

                # Apply preprocessing steps based on the arguments
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

                # Save the preprocessed image in the preprocessed directory
                output_file_path = os.path.join(preprocessed_dir, file_name)
                cv2.imwrite(output_file_path, img)

                print(f"Saved preprocessed image to {output_file_path}")
                metadata["num_images_processed"] += 1
                metadata["processed_files"].append(file_name)
                processed_any = True

        # If no images were processed, we can still create the metadata file
        if not processed_any:
            print("No images processed.")

        # Mark the end time and save metadata file
        metadata["end_time"] = str(datetime.datetime.now())
        metadata["status"] = "completed" if processed_any \
                             else "no images processed"

        # Write the metadata to a JSON file
        metadata_file_path = os.path.join(preprocessed_dir, 'metadata.json')
        with open(metadata_file_path, 'w') as f:
            json.dump(metadata, f, indent=4)

        print(f"Preprocessing complete. Metadata saved"
              f" in {metadata_file_path}")
        return True
