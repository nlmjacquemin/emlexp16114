#!/bin/bash

# Default variables
DEFAULT_WORKING_DIRECTORY="/data"
DEFAULT_INPUT_FOLDER="raw/reads"
DEFAULT_OUTPUT_FOLDER="assembly/flye"
DEFAULT_INPUT_EXTENSION=".fastq.gz"
DEFAULT_LOG_FOLDER=~/jobs

if [[ -z $SLURM_CPUS_PER_TASK ]]; then
    DEFAULT_THREADS=4
else
    DEFAULT_THREADS=$SLURM_CPUS_PER_TASK
fi

show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory         Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -i, --input_folder              Specify the path of the input read folder (default: $DEFAULT_INPUT_FOLDER)"
    echo "  -x, --input_extension           Specify the input reads extension (default: $DEFAULT_INPUT_EXTENSION)"
    echo "  -s, --input_sample              Specify the sample"
    echo "  -o, --output_folder             Specify the path of the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -t, --threads                   Specify the number of threads (default: $DEFAULT_THREADS)"
    echo "  -l, --log_folder                Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
}

# Variables
path_to_working_directory="$DEFAULT_WORKING_DIRECTORY"
input_folder="$DEFAULT_INPUT_FOLDER"
output_folder="$DEFAULT_OUTPUT_FOLDER"
input_extension="$DEFAULT_INPUT_EXTENSION"
input_sample=""
threads="$DEFAULT_THREADS"
log_folder="$DEFAULT_LOG_FOLDER"

# Parse options
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            path_to_working_directory="$2"
            shift 2
        ;;
        -i|--input_folder)
            input_folder="$2"
            shift 2
        ;;
        -x|--input_extension)
            input_extension="$2"
            shift 2
        ;;
        -s|--input_sample)
            input_sample="$2"
            shift 2
        ;;
        -o|--output_folder)
            output_folder="$2"
            shift 2
        ;;
        -t|--threads)
            threads="$2"
            shift 2
        ;;
        -l|--log_folder)
            log_folder="$2"
            shift 2
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

# Check if flye is installed
if ! command -v flye &> /dev/null; then
    echo "Flye could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

# Setting folders and working space
cd $path_to_working_directory
mkdir -p $output_folder

# Running flye
process_sample() {
    echo "Running Flye"
    
    # Setting inputs
    local sample=$1
    local read_file=$(basename $(ls $input_folder/${sample}${input_extension}))
    if [ ! -f "$input_folder/$read_file" ]; then
        echo "File $read_file not found!"
        exit 1
    fi
    
    echo "Sample: $sample"
    echo "Read file: $read_file"
    
    if [ -d "$output_folder/$sample" ]; then
        echo "Assembly for $sample already done, skipping it!"
        exit 0
    fi
    
    flye \
    --pacbio-hifi $input_folder/$read_file \
    --out-dir $output_folder/$sample \
    --threads $threads
    
    echo "Running Flye done!"
    echo "Assembly output for $sample located in $output_folder/$sample"
}

if [ -n "$input_sample" ]; then
    process_sample "$input_sample"
else
    # If no sample is provided, process all samples in the input folder
    for read_file in "$input_folder"/*${input_extension}; do
        read_file=$(basename "$read_file")
        sample=$(echo $read_file | sed -E "s/($input_extension|\.fq|\.fastq)//g")
        process_sample "$sample"
    done
fi
