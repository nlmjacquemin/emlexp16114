#!/bin/bash

# Default values
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY=/data
DEFAULT_INPUT_GENOME_FOLDER="binning/basalt/Final_bestbinset"
DEFAULT_INPUT_EXTENSION=".fa"
DEFAULT_OUTPUT_FOLDER="analysis/checkm"
DEFAULT_THREADS=${SLURM_CPUS_PER_TASK:-4}
DEFAULT_DB_FOLDER="/db"
DEFAULT_DB_FILE="CheckM2_database/uniref100.KO.1.dmnd"

# Show usage information
show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory    Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -i, --input_genome_folder  Specify the path of the input genome folder (default: $DEFAULT_INPUT_GENOME_FOLDER)"
    echo "  -x, --input_extension      Specify the input genome extension (default: $DEFAULT_INPUT_EXTENSION)"
    echo "  -o, --output_folder        Specify the path of the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -l, --log_folder           Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  -t, --threads              Specify the number of threads to use (default: $DEFAULT_THREADS)"
    echo "  -d, --db_folder            Specify the path of the CheckM database folder (default: $DEFAULT_DB_FOLDER)"
    echo "  -f, --db_file              Specify the path of the CheckM2 database folder (default: $DEFAULT_DB_FILE)"
    echo "  --                         Separator to pass additional options to CheckM2"
}

# Default variables
log_folder="$DEFAULT_LOG_FOLDER"
working_directory="$DEFAULT_WORKING_DIRECTORY"
input_genome_folder="$DEFAULT_INPUT_GENOME_FOLDER"
input_extension="$DEFAULT_INPUT_EXTENSION"
output_folder="$DEFAULT_OUTPUT_FOLDER"
db_folder="$DEFAULT_DB_FOLDER"
db_file="$DEFAULT_DB_FILE"
threads="$DEFAULT_THREADS"

# Parse options
while [[ "$1" != "" ]]; do
    case "$1" in
        -w|--working_directory)
            working_directory="$2"
            shift 2
        ;;
        -i|--input_genome_folder)
            input_genome_folder="$2"
            shift 2
        ;;
        -x|--input_extension)
            input_extension="$2"
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
        -d|--db_folder)
            db_folder="$2"
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

# Remaining arguments passed to checkm2
cmd_options=("$@")

# Create log folder if it doesn't exist
mkdir -p "$log_folder"

# Print log message function
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

log_message "Starting CheckM2"

# Change to working directory
cd "$working_directory"

# Get db_path
db_path=$db_folder/$db_file

# Run CheckM2
checkm2 predict \
--input "$input_genome_folder" \
--extension "$input_extension" \
--output_directory "$output_folder" \
--database_path "$db_path" \
--threads "$threads" "${cmd_options[@]}"

log_message "CheckM2 analysis finished"
