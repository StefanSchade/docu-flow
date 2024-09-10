import os
import cv2
from pipeline.pipeline_step import PipelineStep


class PreprocessStep(PipelineStep):
    
    def __init__(self, args):
        self.args = args


    def run(self, input_data):
        print(f"Preprocessing data in {input_data}")

        # Example: Create a 'preprocessed' dir and simulate image processing
        preprocessed_dir = os.path.join(input_data,
                                        'preprocessed')
        if not os.path.exists(preprocessed_dir):
            os.makedirs(preprocessed_dir)

        # List all image files in the input directory
        for file_name in os.listdir(input_data):
            if file_name.endswith((".png", ".jpg", ".jpeg")):  # Assuming we're processing image files
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
                        cv2.THRESH_BINARY, self.args.block_size, self.args.noise_constant
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


        print(f"Preprocessing complete. Output saved in {preprocessed_dir}")
        return True
