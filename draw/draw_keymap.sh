#!/bin/bash

# Script to generate keymap SVG using keymap-drawer
# Requires: keymap-drawer (install with: pip install keymap-drawer)

set -e

# Default values
OUTPUT_DIR="."
KEYMAP_FILE=""
LAYOUT_FILE=""

# Parse command line arguments
while getopts "o:f:d:h" opt; do
  case $opt in
  o)
    OUTPUT_DIR="$OPTARG"
    ;;
  f)
    KEYMAP_FILE="$OPTARG"
    ;;
  d)
    LAYOUT_FILE="$OPTARG"
    ;;
  h)
    echo "Usage: $0 -f <keymap_file> [-o <output_directory>] [-d <layout_file>]"
    echo ""
    echo "Options:"
    echo "  -f <keymap_file>      Path to the ZMK keymap file (required)"
    echo "  -o <output_directory> Output directory for the SVG (default: current directory)"
    echo "  -d <layout_file>      Path to devicetree layout file (optional)"
    echo "  -h                    Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -f config/corne_choc_pro.keymap -o output/"
    echo "  $0 -f config/corne_choc_pro.keymap -d boards/arm/corne_choc_pro/corne_choc_pro.dtsi -o output/"
    exit 0
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    echo "Use -h for help" >&2
    exit 1
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
  esac
done

# Check if keymap file is provided
if [ -z "$KEYMAP_FILE" ]; then
  echo "Error: Keymap file is required. Use -f to specify the keymap file." >&2
  echo "Use -h for help" >&2
  exit 1
fi

# Check if keymap file exists
if [ ! -f "$KEYMAP_FILE" ]; then
  echo "Error: Keymap file '$KEYMAP_FILE' not found." >&2
  exit 1
fi

# Check if layout file exists (if provided)
if [ -n "$LAYOUT_FILE" ] && [ ! -f "$LAYOUT_FILE" ]; then
  echo "Error: Layout file '$LAYOUT_FILE' not found." >&2
  exit 1
fi

# Create output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Creating output directory: $OUTPUT_DIR"
  mkdir -p "$OUTPUT_DIR"
fi

# Check if keymap-drawer is installed
if ! command -v keymap &>/dev/null; then
  echo "Error: keymap-drawer is not installed." >&2
  echo "Install it with: pip install keymap-drawer" >&2
  exit 1
fi

# Extract the base name of the keymap file (without extension)
BASENAME=$(basename "$KEYMAP_FILE" .keymap)

# Define output file path
OUTPUT_FILE="$OUTPUT_DIR/keymap.svg"

echo "Generating keymap SVG..."
echo "  Input:  $KEYMAP_FILE"
echo "  Output: $OUTPUT_FILE"

# Parse the ZMK keymap and generate SVG
# Using keymap parse to convert ZMK keymap to YAML, then keymap draw to create SVG
TEMP_YAML=$(mktemp)
trap "rm -f $TEMP_YAML" EXIT

# Parse ZMK keymap to YAML format
echo "Parsing ZMK keymap..."
keymap parse -z "$KEYMAP_FILE" >"$TEMP_YAML"

# Generate SVG from YAML
echo "Drawing SVG..."
if [ -n "$LAYOUT_FILE" ]; then
  echo "Using layout file: $LAYOUT_FILE"
  keymap draw -d "$LAYOUT_FILE" "$TEMP_YAML" >"$OUTPUT_FILE"
else
  keymap draw "$TEMP_YAML" >"$OUTPUT_FILE"
fi

echo "✓ Successfully generated keymap SVG: $OUTPUT_FILE"
