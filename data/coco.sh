#!/bin/bash

set -eo pipefail

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"
echo "SCRIPTPATH: $SCRIPTPATH"
cd "$SCRIPTPATH"

# Function to show help
show_help() {
    echo "COCO Dataset Download Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --all          Download all splits (train + validation + annotations)"
    echo "  --val          Download only validation split"
    echo "  --train        Download only train split"
    echo "  --annotations  Download only annotations"
    echo "  --clean        Remove existing files before downloading"
    echo "  --help         Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                       # Show this help message (default)"
    echo "  $0 --all                 # Download all splits and annotations"
    echo "  $0 --val                 # Download only validation split"
    echo "  $0 --train               # Download only train split"
    echo "  $0 --annotations         # Download only annotations"
    echo "  $0 --val --annotations   # Download validation split and annotations"
    echo "  $0 --all --clean         # Clean and download everything"
    echo ""
}

# Parse arguments
DOWNLOAD_VAL=false
DOWNLOAD_TRAIN=false
DOWNLOAD_ANNOTATIONS=false
CLEAN=false

# If no arguments, show help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            DOWNLOAD_VAL=true
            DOWNLOAD_TRAIN=true
            DOWNLOAD_ANNOTATIONS=true
            shift
            ;;
        --val)
            DOWNLOAD_VAL=true
            shift
            ;;
        --train)
            DOWNLOAD_TRAIN=true
            shift
            ;;
        --annotations)
            DOWNLOAD_ANNOTATIONS=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown flag: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Clean entire coco directory if --clean flag is set
if [ "$CLEAN" = true ]; then
    echo "Cleaning entire coco directory..."
    if [ -d "coco" ]; then
        rm -rf "coco"
        echo "Removed entire coco directory"
    fi
fi

# Create data directory
mkdir -m 777 -p coco

# Function for downloading and extracting split
download_split() {
    local split=$1
    local url=$2

    echo "Downloading $split split..."

    # Check if file already exists
    if [ -f "coco/${split}2014.zip" ] && [ "$CLEAN" = false ]; then
        echo "File coco/${split}2014.zip already exists, skipping download"
    else
        wget --progress=dot:giga --output-file=/dev/stdout -O "coco/${split}2014.zip" "$url"
    fi

    # Extract if directory doesn't exist or clean mode is enabled
    if [ ! -d "coco/$split" ] || [ "$CLEAN" = true ]; then
        echo "Extracting $split split..."
        unzip -q "coco/${split}2014.zip" -d "coco/"
        rm "coco/${split}2014.zip"
    else
        echo "Directory coco/$split already exists, skipping extraction"
    fi
}

# Function for downloading and extracting annotations
download_annotations() {
    echo "Downloading annotations..."

    # Check if file already exists
    if [ -f "coco/annotations_trainval2014.zip" ] && [ "$CLEAN" = false ]; then
        echo "File coco/annotations_trainval2014.zip already exists, skipping download"
    else
        wget --progress=dot:giga --output-file=/dev/stdout -O "coco/annotations_trainval2014.zip" "http://images.cocodataset.org/annotations/annotations_trainval2014.zip"
    fi

    # Extract if directory doesn't exist or clean mode is enabled
    if [ ! -d "coco/annotations" ] || [ "$CLEAN" = true ]; then
        echo "Extracting annotations..."
        unzip -q "coco/annotations_trainval2014.zip" -d "coco/"
        rm "coco/annotations_trainval2014.zip"
    else
        echo "Directory coco/annotations already exists, skipping extraction"
    fi
}

# Download splits and annotations
if [ "$DOWNLOAD_VAL" = true ]; then
    download_split "val" "http://images.cocodataset.org/zips/val2014.zip"
fi

if [ "$DOWNLOAD_TRAIN" = true ]; then
    download_split "train" "http://images.cocodataset.org/zips/train2014.zip"
fi

if [ "$DOWNLOAD_ANNOTATIONS" = true ]; then
    download_annotations
fi

echo "Done!"
