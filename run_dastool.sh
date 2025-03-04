#!/bin/bash

# Default values
DEFAULT_WORKING_DIRECTORY="/data"
DEFAULT_INPUT_BIN_FOLDER="raw"
DEFAULT_INPUT_CONTIGS_FOLDER="raw"
DEFAULT_INPUT_CONTIGS_FILE="*.fna"
DEFAULT_OUTPUT_FOLDER="analysis/dastool"
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_THREADS=20

show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory          Specify the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -b, --input_bin_folder           Specify the input bin folder (default: $DEFAULT_INPUT_BIN_FOLDER)"
    echo "  -c, --input_contigs_folder       Specify the input contigs folder (default: $DEFAULT_INPUT_CONTIGS_FOLDER)"
    echo "  -y, --input_contigs_file         Specify the input contigs file (default: $DEFAULT_INPUT_CONTIGS_FILE)"
    echo "  -o, --output_folder              Specify the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -l, --log_folder                 Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  -t, --threads                    Number of threads (default: $DEFAULT_THREADS)"
    echo "  --                               Separator to pass additional DAS Tool options"
    echo "  -h, --help                       Display this help message"
}

# Variables
working_directory="$DEFAULT_WORKING_DIRECTORY"
input_bin_folder="$DEFAULT_INPUT_BIN_FOLDER"
input_contigs_folder="$DEFAULT_INPUT_CONTIGS_FOLDER"
input_contigs_file="$DEFAULT_INPUT_CONTIGS_FILE"
output_folder="$DEFAULT_OUTPUT_FOLDER"
log_folder="$DEFAULT_LOG_FOLDER"
threads="$DEFAULT_THREADS"
dastool_cmd=""

# Parse command-line arguments
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            working_directory="$2"
            shift 2
        ;;
        -b|--input_bin_folder)
            input_bin_folder="$2"
            shift 2
        ;;
        -c|--input_contigs_folder)
            input_contigs_folder="$2"
            shift 2
        ;;
        -y|--input_contigs_file)
            input_contigs_file="$2"
            shift 2
        ;;
        -o|--output_folder)
            output_folder="$2"
            shift 2
        ;;
        -l|--log_folder)
            log_folder="$2"
            shift 2
        ;;
        -t|--threads)
            threads="$2"
            shift 2
        ;;
        --)
            shift
            break
        ;;
        -h|--help)
            show_usage
            exit 0
        ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
        ;;
    esac
done

dastool_cmd=($@)

log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Check if DAS Tool is installed
if ! command -v DAS_Tool &> /dev/null; then
    log_message "DAS Tool could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

# Setting up working directory
cd "$working_directory"
mkdir -p "$output_folder"

# Gathering binning results
contig2bin_files=""
labels=""
for file in $(ls "$input_bin_folder"/*.tsv 2>/dev/null); do
    file_name=$(basename "$file")
    label_name=${file_name%.tsv}
    if [ -z "$contig2bin_files" ]; then
        contig2bin_files="$file"
        labels="$label_name"
    else
        contig2bin_files+="","$file"
        labels+="","$label_name"
    fi
done

if [ -z "$contig2bin_files" ]; then
    log_message "No binning result files found in $input_bin_folder. Aborting."
    exit 1
fi

log_message "Running DAS Tool with bins: $contig2bin_files"

# Running DAS Tool
/opt/DAS_Tool-1.1.6/DAS_Tool \
-i "$contig2bin_files" \
-l ""$labels"" \
-c "$input_contigs_folder/$input_contigs_file" \
-o "$output_folder/dastool_output" \
--write_bins \
-t "$threads" \
${dastool_cmd[@]}

log_message "DAS Tool execution completed."
