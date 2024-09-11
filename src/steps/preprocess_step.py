import os
import cv2
import json
import datetime
from pipeline.pipeline_step import PipelineStep


class PreprocessStep(PipelineStep):

    def __init__(self, args):
        self.args = args

    def run(self, input_data):
        print(f"Preprocessing data in {input_data}")

        # Metadata dictionary to store information about the step
        metadata = {
            "start_time": str(datetime.datetime.now()),
            "num_images_processed": 0,
            "parameters": {
                "grayscale": self.args.grayscale,
                "remove_noise": self.args.remove_noise,
                "threshold": self.args.threshold,
                "adaptive_threshold": self.args.adaptive_threshold,
                "block_size": self.args.block_size,
                "noise_constant": self.args.noise_constant,
                "dilate": self.args.dilate,
                "erode": self.args.erode,
                "invert": self.args.invert,
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
                if self.args.grayscale:
                    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                if self.args.remove_noise:
                    img = cv2.medianBlur(img, 5)
                if self.args.threshold:
                    _, img = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
                if self.args.adaptive_threshold:
                    img = cv2.adaptiveThreshold(
                        img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                        cv2.THRESH_BINARY, self.args.block_size,
                        self.args.noise_constant
                    )
                if self.args.dilate:
                    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
                    img = cv2.dilate(img, kernel, iterations=1)
                if self.args.erode:
                    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
                    img = cv2.erode(img, kernel, iterations=1)
                if self.args.invert:
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
