#!/bin/bash

START_SERVICES=1

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Install Gesund Platform"
    echo "Options:"
    echo "  -t, --tarball NAME     Specify the name of the encrypted tarball on S3 (required)"
    echo "  -p, --decryption-password PASSWORD   Specify the decryption password (required)"
    echo "  -h, --help             Show this help message and exit"
}

handle_error() {
    echo "Error: $1" >&2
    exit 1
}

# Function to show a spinner while a command is running
spinner() {
    local pid=$1
    local delay=0.25
    local spinstr="/|\\-"
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

wait_for_container() {
    local container_name="$1"
    local max_attempts=60  
    local wait_seconds=2

    for ((i = 0; i < max_attempts; i++)); do
        if docker ps --format "{{.Names}}" | grep -q "$container_name"; then
            local container_status=$(docker inspect -f "{{.State.Status}}" "$container_name")
            if [ "$container_status" == "running" ]; then
                echo "$container_name is ready."
                return 0
            fi
        fi
        sleep "$wait_seconds"
    done

    echo "Timed out waiting for $container_name to be ready."
    exit 1
}


# Check if required dependencies are available
command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required but not installed. Aborting."; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo >&2 "openssl is required but not installed. Aborting."; exit 1; }
command -v tar >/dev/null 2>&1 || { echo >&2 "tar is required but not installed. Aborting."; exit 1; }

# Parse command line options using getopt
OPTIONS=$(getopt -o t:p:h --long tarball:,decryption-password:,help -n 'gesund-platform-installer.sh' -- "$@")
eval set -- "$OPTIONS"

# Parse named parameters
while true; do
    case "$1" in
        -t | --tarball)
            ENCRYPTED_TARBALL_NAME="$2"
            shift 2
            ;;
        -p | --decryption-password)
            DECRYPTION_PASSWORD="$2"
            shift 2
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Check if required parameters are provided
if [ -z "$ENCRYPTED_TARBALL_NAME" ]; then
    echo "Error: Encrypted tarball name not provided (--tarball option)"
    show_help
    exit 1
fi
if [ -z "$DECRYPTION_PASSWORD" ]; then
    echo "Error: Decryption password not provided (--decryption-password option)"
    show_help
    exit 1
fi

# Check if encrypted tarball already exists
if [ -e "encrypted_tarball.tar.gz.enc" ]; then
    echo "Encrypted tarball already exists. Skipping download."
else
    S3_URL="https://gesund-platform-releases.s3.amazonaws.com/$ENCRYPTED_TARBALL_NAME"
    
    HTTP_STATUS=$(curl -Is --head -w "%{http_code}" "$S3_URL" -o /dev/null)

    if [ "$HTTP_STATUS" -eq 200 ]; then
        
        echo "Downloading encrypted tarball from $S3_URL"
        curl -# -o encrypted_tarball.tar.gz.enc "$S3_URL" || handle_error "Failed to download encrypted tarball"
    else
        echo "The file may not be accessible or do not exist."
        echo "Check the tarball name or get in touch with Gesund team."
        handle_error "HTTP status code: $HTTP_STATUS"
    fi

fi

# Check if decrypted tarball already exists
if [ -e "decrypted_tarball.tar.gz" ]; then
    echo "Decrypted tarball already exists. Skipping decryption."
else
    # Decrypt the downloaded tarball with a progress bar
    echo "Decrypting the downloaded tarball..."
    (openssl aes-256-cbc -pbkdf2 -d -in encrypted_tarball.tar.gz.enc -out decrypted_tarball.tar.gz -k "$DECRYPTION_PASSWORD" || handle_error "Failed to decrypt tarball") &
    spinner $!
fi


if [ -d "gesund_platform" ]; then
    echo "Tarball already unpacked."
else
    # Unpack the decrypted tarball with a progress bar
    echo "Unpacking decrypted tarball..."
    (tar -xvzf decrypted_tarball.tar.gz gesund_platform || handle_error "Failed to unpack decrypted tarball") &
    spinner $!
fi

# Change directory to gesund_platform
cd gesund_platform || handle_error "No directory gesund_platform"
if [ -d "venv" ]; then
    rm -rf venv
fi

# Create and activate Python virtual environment
echo "Creating python virtual environment."
python3 -m venv venv || handle_error "Could not create virtual env"
source venv/bin/activate

# Update pip and install gesund platform CLI
echo "Updating pip packages"
pip install -U pip || handle_error "Failed to update pip"
GESUND_CLI_EXC=$(readlink -m venv/bin/gesund)
GESUND_CLI_WHEEL=$(ls ./*.whl| head -1)
echo "Installing gesund platform cli...$GESUND_CLI_WHEEL"
pip install "$GESUND_CLI_WHEEL" --no-index --find-links wheels || handle_error "Failed to install gesund platform CLI"

# Add alias to .bashrc
echo "Successfully installed gesund cli"
echo "Please note: added following command to .bashrc file"
echo "alias gesund=$GESUND_CLI_EXC" >> ~/.bashrc || handle_error "Failed to add alias to .bashrc"



if [ "$START_SERVICES" -eq 1 ]; ¬then
    LOG_FILE="gesund-installation-cli.log"

    echo "Starting gesund services"
    echo "You can view the installation logs in '$LOG_FILE' or on the screen using 'tail -f $LOG_FILE'."
    nohup gesund start --fresh --web > "$LOG_FILE" 2>&1 &


    echo "Waiting for Application startup to complete"
    while ! grep -q "Application startup complete." "$LOG_FILE"; do
        sleep 1
    done

    echo Checking if services are in a healthy state
    containers=("mongodb" "autodeploy" "mlutility" "db_manager" "nodejs-tool" "validation" "rabbitmq" "web-server" "web-client")
    for container in "${containers[@]}"; do
        wait_for_container "$container"
    done

    echo "All services are ready. Installation successful."
    exit
fi

echo "Gesund Platform installation done."