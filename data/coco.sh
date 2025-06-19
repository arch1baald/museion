#!/bin/bash

set -eo pipefail

# Get project root path
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

# Create data directory
mkdir -m 777 -p coco

# Function to clean split files
clean_split() {
    local split=$1
    echo "Cleaning $split split..."
    if [ -d "coco/$split" ]; then
        rm -rf "coco/$split"
        echo "Removed directory coco/$split"
    fi
    if [ -f "coco/${split}.zip" ]; then
        rm -f "coco/${split}.zip"
        echo "Removed file coco/${split}.zip"
    fi
}

# Function to clean annotations
clean_annotations() {
    echo "Cleaning annotations..."
    if [ -d "coco/annotations" ]; then
        rm -rf "coco/annotations"
        echo "Removed directory coco/annotations"
    fi
    if [ -f "coco/annotations_trainval2014.zip" ]; then
        rm -f "coco/annotations_trainval2014.zip"
        echo "Removed file coco/annotations_trainval2014.zip"
    fi
}

# Function for downloading and extracting split
download_split() {
    local split=$1
    local url=$2

    echo "Downloading $split split..."

    # Check if file already exists
    if [ -f "coco/${split}.zip" ] && [ "$CLEAN" = false ]; then
        echo "File coco/${split}.zip already exists, skipping download"
    else
        wget -O "coco/${split}.zip" "$url"
    fi

    # Extract if directory doesn't exist or clean mode is enabled
    if [ ! -d "coco/$split" ] || [ "$CLEAN" = true ]; then
        echo "Extracting $split split..."
        unzip -q "coco/${split}.zip" -d "coco/"

        # Rename directory if needed (COCO extracts as train2014/val2014)
        if [ "$split" = "train" ] && [ -d "coco/train2014" ]; then
            mv "coco/train2014" "coco/train"
        elif [ "$split" = "val" ] && [ -d "coco/val2014" ]; then
            mv "coco/val2014" "coco/val"
        fi
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
        wget -O "coco/annotations_trainval2014.zip" "http://images.cocodataset.org/annotations/annotations_trainval2014.zip"
    fi

    # Extract if directory doesn't exist or clean mode is enabled
    if [ ! -d "coco/annotations" ] || [ "$CLEAN" = true ]; then
        echo "Extracting annotations..."
        unzip -q "coco/annotations_trainval2014.zip" -d "coco/"
    else
        echo "Directory coco/annotations already exists, skipping extraction"
    fi
}

# Clean files if needed
if [ "$CLEAN" = true ]; then
    if [ "$DOWNLOAD_VAL" = true ]; then
        clean_split "val"
    fi
    if [ "$DOWNLOAD_TRAIN" = true ]; then
        clean_split "train"
    fi
    if [ "$DOWNLOAD_ANNOTATIONS" = true ]; then
        clean_annotations
    fi
fi

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
