#!/bin/bash

# Default values
DEFAULT_LOG_FOLDER=~/jobs
DEFAULT_WORKING_DIRECTORY=/data
DEFAULT_INPUT_GENOME_FOLDER="binning/basalt/Final_bestbinset"
DEFAULT_INPUT_EXTENSION="fa"
DEFAULT_INPUT_DB_FOLDER="/db/release220"
DEFAULT_OUTPUT_FOLDER="analysis/gtdb"

# Show usage information
show_usage() {
    echo "Usage: $0"
    echo "Options:"
    echo "  -w, --working_directory		Specify the path of the working directory (default: $DEFAULT_WORKING_DIRECTORY)"
    echo "  -i, --input_genome_folder	Specify the path of the input genome folder (default: $DEFAULT_INPUT_GENOME_FOLDER)"
    echo "  -x, --input_extension		Specify the input genome extension (default: $DEFAULT_INPUT_GENOME_EXTENSION)"
    echo "  -d, --input_db_folder		Specify the path of the input database folder (default: $DEFAULT_INPUT_DB_FOLDER)"
    echo "  -o, --output_folder			Specify the path of the output folder (default: $DEFAULT_OUTPUT_FOLDER)"
    echo "  -l, --log_folder			Specify the log folder (default: $DEFAULT_LOG_FOLDER)"
    echo "  --							Separator to pass following options to the command being executed"
    echo "	[gtdbtk_options]		    Options for the gtdbtk classify_wf command"
}

# Default variables
log_folder="$DEFAULT_LOG_FOLDER"
working_directory="$DEFAULT_WORKING_DIRECTORY"
input_genome_folder="$DEFAULT_INPUT_GENOME_FOLDER"
input_extension="$DEFAULT_INPUT_EXTENSION"
input_db_folder="$DEFAULT_INPUT_DB_FOLDER"
output_folder="$DEFAULT_OUTPUT_FOLDER"

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
        -d|--input_db_folder)
            input_db_folder="$2"
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

# Remaining arguments are for the script to run
cmd_options=("$@")

# Function to print log messages with timestamp
log_message() {
    local message=$@
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "[${timestamp}] ${message}"
}

# Exporting database
export GTDBTK_DATA_PATH=$input_db_folder

# Check if gtdbtk is installed
if ! command -v gtdbtk &> /dev/null; then
    log_message "gtdbtk could not be found. Please install it and ensure it's in your PATH."
    exit 1
fi

log_message "Displaying CPUs and memory allocated and preparing output folder..."
cd "$working_directory"
echo -e "CPUs: $SLURM_CPUS_PER_TASK"
echo -e "Memory: $(( $SLURM_CPUS_PER_TASK * $SLURM_MEM_PER_CPU / 1000 ))"
echo -e "Creating output folder: $output_folder"
mkdir -p "$output_folder"
log_message "Displaying CPUs and memory allocated and preparing output folder done!"

log_message "Running gtdbtk classify_wf"
gtdbtk classify_wf \
--genome_dir "$input_genome_folder" \
-x $input_extension \
--out_dir "$output_folder" \
--mash_db "$output_folder"/mash_db \
--cpus "$SLURM_CPUS_PER_TASK" "${cmd_options[@]}"
log_message "gtdbtk done!"
