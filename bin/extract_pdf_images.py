#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#   "PyMuPDF",
# ]
# ///
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import fitz  # PyMuPDF
import os
import sys


def extract_images_from_pdf(pdf_path, output_dir):
    """Extracts images from a PDF and saves them to a directory."""
    if not os.path.exists(output_dir):
        print(f"Creating output directory: {output_dir}")
        os.makedirs(output_dir)

    try:
        doc = fitz.open(pdf_path)
    except Exception as e:
        print(f"Error opening PDF file: {e}")
        return

    image_count = 0
    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        image_list = page.get_images(full=True)

        if not image_list:
            continue

        for image_index, img in enumerate(image_list):
            xref = img[0]
            base_image = doc.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]

            image_filename = f"page{page_num + 1}_img{image_index + 1}.{image_ext}"
            image_path = os.path.join(output_dir, image_filename)

            try:
                with open(image_path, "wb") as image_file:
                    image_file.write(image_bytes)
                image_count += 1
                print(f"Saved image: {image_path}")
            except Exception as e:
                print(f"Error saving image {image_path}: {e}")

    if image_count == 0:
        print("No images found in the PDF.")
    else:
        print(f"\nSuccessfully extracted {image_count} images.")

    doc.close()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python extract_pdf_images.py <path_to_pdf> <output_directory>")
        sys.exit(1)

    pdf_path_arg = sys.argv[1]
    output_dir_arg = sys.argv[2]

    extract_images_from_pdf(pdf_path_arg, output_dir_arg)
