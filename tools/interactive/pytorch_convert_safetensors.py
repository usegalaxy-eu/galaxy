#!/usr/bin/env python

import argparse
import os
import sys
import glob
from pathlib import Path

from safetensors.torch import save_file

import torch


def convert_pt_to_safetensors(input_path, output_path):
    """Convert PyTorch model to SafeTensors format."""
    print(f"Loading PyTorch model from: {input_path}")

    try:
        # Load the PyTorch model
        state_dict = torch.load(input_path)

        print(f"Converting {len(state_dict)} tensors to SafeTensors format...")

        # Save as SafeTensors
        save_file(state_dict, output_path)
        print(f"Successfully converted to SafeTensors: {output_path}")

    except Exception as e:
        print(f"Error converting PyTorch to SafeTensors: {e}")
        sys.exit(1)


def convert_directory(models_dir, output_dir):
    """Convert all PyTorch model files in a directory to SafeTensors format."""

    # Creating output directory (if not there)
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    # Getting all files
    model_files = glob.glob(os.path.join(models_dir, "*"))

    model_files = [f for f in model_files if os.path.isfile(f)]

    if not model_files:
        print(f"No files found in {models_dir}")
        return

    print(f"Found {len(model_files)} files to convert...")

    for file_path in model_files:
        # Get the basename
        basename = os.path.basename(file_path)

        # Create output filename
        output_filename = f"{basename}.safetensors"
        output_path = os.path.join(output_dir, output_filename)

        print(f"\nProcessing: {basename}")

        convert_pt_to_safetensors(file_path, output_path)


def main():
    parser = argparse.ArgumentParser(
        description="Convert PyTorch to SafeTensors",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Convert single file
  python3 converter.py --convert pt_safe -i model.pt -o model.safetensors

  # Convert all files in directory
  python3 converter.py --convert pt_safe --batch -i ./models -o ./models/safe
        """
    )

    parser.add_argument(
        "--convert",
        required=True,
        choices=["pt_safe"],
        help=(
            "Conversion direction: 'pt_safe' (PyTorch to SafeTensors)"
        )
    )

    parser.add_argument(
        "-i", "--input",
        required=True,
        help="Input model file path or directory (for batch mode)"
    )

    parser.add_argument(
        "-o", "--output",
        required=True,
        help="Output model file path or directory (for batch mode)"
    )

    parser.add_argument(
        "--batch",
        action="store_true",
        help="Batch mode: convert all files in input directory"
    )

    args = parser.parse_args()

    # Validate input exists
    if not os.path.exists(args.input):
        print(f"Error: Input path does not exist: {args.input}")
        sys.exit(1)

    # Perform conversion
    if args.convert == "pt_safe":
        if args.batch:
            # Batch mode: converting directory
            if not os.path.isdir(args.input):
                print(f"Error: Input must be a directory for batch mode: {args.input}")
                sys.exit(1)

            convert_directory(args.input, args.output)
        else:
            # Single file mode
            if not os.path.isfile(args.input):
                print(f"Error: Input file does not exist: {args.input}")
                sys.exit(1)

            # Create output directory if it doesn't exist
            output_dir = os.path.dirname(args.output)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir)
                print(f"Created output directory: {output_dir}")

            convert_pt_to_safetensors(args.input, args.output)


if __name__ == "__main__":
    main()
