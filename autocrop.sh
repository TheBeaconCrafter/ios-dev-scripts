#!/bin/bash

show_usage() {
    echo "Usage: $0 -i <input-file> -o <output-dir> -t <template>"
    echo "  -i, --input     Path to the input image file."
    echo "  -o, --output    Path to the output directory. Defaults to './processed'."
    echo "  -t, --template  Template type: iOS, macOS, webext."
    exit 1
}

# Default output directory is processed, override with -o
output_dir="./processed"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--input) input_file="$2"; shift ;;
        -o|--output) output_dir="$2"; shift ;;
        -t|--template) template="$2"; shift ;;
        *) echo "Unknown parameter: $1"; show_usage ;;
    esac
    shift
done

# Validate input
if [[ -z "$input_file" || -z "$template" ]]; then
    echo "Error: Input file and template are required."
    show_usage
fi

# Ensure input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file does not exist."
    exit 1
fi

mkdir -p "$output_dir"

process_images() {
    local template_type=$1
    local sizes=()
    local names=()

    case $template_type in
        iOS)
            sizes=(40 60 80 120 180 1024)
            names=("icon-40.png" "icon-60.png" "icon-80.png" "icon-120.png" "icon-180.png" "icon-1024.png")
            ;;
        macOS)
            sizes=(16 32 64 128 256 512 1024)
            names=("icon-16.png" "icon-32.png" "icon-64.png" "icon-128.png" "icon-256.png" "icon-512.png" "icon-1024.png")
            ;;
        webext)
            sizes=(48 96 128 256 512)
            names=("icon-48.png" "icon-96.png" "icon-128.png" "icon-256.png" "icon-512.png")
            ;;
        *)
            echo "Error: Invalid template type. Must be one of: iOS, macOS, webext."
            exit 1
            ;;
    esac

    for i in "${!sizes[@]}"; do
        local size="${sizes[$i]}"
        local output_file="$output_dir/${names[$i]}"
        sips -z "$size" "$size" "$input_file" --out "$output_file" > /dev/null
        echo "Created: $output_file"
    done
}

process_images "$template"

echo "Processing completed. Files saved in '$output_dir'."
