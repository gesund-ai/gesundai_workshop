#!/bin/bash

echo ""
echo "Welcome to the Gesund Platform Installer!"
echo "This script will help you install the Gesund Platform."
echo ""


function internet_access() {
    ping -c 1 -W 1 google.com > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

function check_package_dependency() {
    if ! dpkg -l | grep -q "^ii  $1"; then
        return 1
    fi
    return 0
}

function check_and_install_dependencies() {
    
    echo "Checking for dependencies"

    # Check and install missing dependencies
    MISSING_DEPENDENCIES=()
    command -v docker >/dev/null 2>&1 || MISSING_DEPENDENCIES+=("docker")
    command -v docker-compose >/dev/null 2>&1 || MISSING_DEPENDENCIES+=("docker-compose")
    command -v python3 >/dev/null 2>&1 || MISSING_DEPENDENCIES+=("python3")    
    command -v curl >/dev/null 2>&1 || MISSING_DEPENDENCIES+=("curl")
    command -v openssl >/dev/null 2>&1 || MISSING_DEPENDENCIES+=("openssl")
    command -v tar >/dev/null 2>&1 || MISSING_DEPENDENCIES+=("tar")

    check_package_dependency "python3-venv" || MISSING_DEPENDENCIES+=("python3-venv")
    
    # required for opencv
    check_package_dependency "libgl1" || MISSING_DEPENDENCIES+=("libgl1")

    if [ ${#MISSING_DEPENDENCIES[@]} -gt 0 ]; then
        echo "The following dependencies are missing: ${MISSING_DEPENDENCIES[*]}"
        echo "Installing dependencies requires internet access."
        echo "Do you want to install these missing dependencies? (yes/no)"
        read -r INSTALL_MISSING_DEPENDENCIES

        if [[ $INSTALL_MISSING_DEPENDENCIES == "yes" ]]; then
            if [ "$EUID" -ne 0 ]; then
                echo "Installing dependencies requires root privileges. Please run this script as root or with sudo."
                exit 1
            fi

            if ! internet_access; then
                echo "No internet access detected. Please check your internet connection."
                exit 1
            fi 

            apt-get update
            
            if [[ " ${MISSING_DEPENDENCIES[@]} " =~ "docker" ]]; then
                apt-get install docker.io
            fi
            if [[ " ${MISSING_DEPENDENCIES[@]} " =~ "docker-compose" ]]; then
                apt-get install docker-compose
            fi
            if [[ " ${MISSING_DEPENDENCIES[@]} " =~ "python3" ]]; then
                apt-get install python3
            fi
            if [[ " ${MISSING_DEPENDENCIES[@]} " =~ "python3-venv" ]]; then
                apt-get install python3-venv
            fi
            if [[ " ${MISSING_DEPENDENCIES[@]} " =~ "curl" ]]; then
                apt-get install curl
            fi
            if [[ " ${MISSING_DEPENDENCIES[@]} " =~ "openssl" ]]; then
                apt-get install openssl
            fi
            if [[ " ${MISSING_DEPENDENCIES[@]} " =~ "tar" ]]; then
                apt-get install tar
            fi
            echo "Dependencies installed successfully."
        else
            echo "Installation aborted. Please install the missing dependencies and run the script again."
            echo "To install the missing dependencies manually, you can use the following commands:"
            echo "For example, to install python3-venv:"
            echo "sudo apt-get install python3-venv"

            exit 1
        fi
    else
        echo "All required dependencies are already installed."
    fi
} 

check_and_install_dependencies

START_SERVICES=0


# Parse command line options using getopt
OPTIONS=$(getopt -o t:p:sh --long tarball:,decryption-password:,start-services,help -n 'gesund-platform-installer.sh' -- "$@")
eval set -- "$OPTIONS"

# Parse named parameters
while true; do
    case "$1" in
        -t | --tarball)
            TARBALL_NAME="$2"
            shift 2
            ;;
        -p | --decryption-password)
            DECRYPTION_PASSWORD="$2"
            shift 2
            ;;
        -s | --start-services)
            START_SERVICES=1
            shift
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
if [ -z "$TARBALL_NAME" ]; then
    echo "Error: Tarball name not provided (--tarball option)"
    show_help
    exit 1
fi


function show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Install Gesund Platform"
    echo "Options:"
    echo "  -t, --tarball NAME     Specify the name of the tarball on S3 (required)"
    echo "  -p, --decryption-password PASSWORD   Specify the decryption password (optional)"
    echo "  -s, --start-services    Start platform services after installation (optional)"
    echo "  -h, --help             Show this help message and exit"
}

# Function to show a spinner while a command is running
function spinner() {
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

function wait_for_container() {
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


function wait_for_container {
    echo Checking if services are in a healthy state
    containers=("mongodb" "autodeploy" "mlutility" "db_manager" "nodejs-tool" "validation" "rabbitmq" "web-server" "web-client")
    for container in "${containers[@]}"; do
        wait_for_container "$container"
    done
    echo "All services are ready. Installation successful."
}

function start_gesund {
    set -a; source .env.docker; set +a; 
    
    nohup gesund start --fresh --web > "$LOG_FILE" 2>&1 & tail -f "$LOG_FILE" & 
    echo "Started gesund. PID: $!"
}


function decrypt_tarball(){
    local tarball="$1"
    local password="$2"

    TARBALL_NAME=${tarball%.enc} # remove .enc extensions

    if [ -e "$TARBALL_NAME" ]; then
        echo "Decrypted tarball already exists. Skipping decryption."
    else
        echo "Decrypting the tarball..."
        
        if [ -z "$password" ]; then
            echo "Error: Decryption password not provided (--decryption-password option)"
            exit 1
        fi
        
        (openssl aes-256-cbc -pbkdf2 -d -in $tarball -out $TARBALL_NAME -k "$password" || handle_error "Failed to decrypt tarball") &
        spinner $!
    fi
}

function unpack_tarball(){
    local tarball="$1"
    if [ -d "gesund_platform" ]; then
        echo "Tarball already unpacked."
    else
        echo "Unpacking decrypted tarball..."
        (tar -xzf $tarball gesund_platform || handle_error "Failed to unpack decrypted tarball") &
        spinner $!
    fi
}

function download_tarball(){
    local tarball="$1"

    S3_URL="https://gesund-platform-releases.s3.amazonaws.com/$tarball"

    HTTP_STATUS=$(curl -Is --head -w "%{http_code}" "$S3_URL" -o /dev/null)

    if [ "$HTTP_STATUS" -eq 200 ]; then

        echo "Downloading tarball from $S3_URL"
        curl -# -o $tarball "$S3_URL" || handle_error "Failed to download tarball"
    else
        echo "The file may not be accessible or do not exist."
        echo "Check the tarball name or get in touch with Gesund team."
        handle_error "HTTP status code: $HTTP_STATUS"
    fi

}

# Check if tarball already exists
if [ -e "$TARBALL_NAME" ]; then
    
    echo "Tarball $TARBALL_NAME found. Skipping donwload." 

    if [[ "$TARBALL_NAME" == *.tar.gz.enc ]]; then
        decrypt_tarball $TARBALL_NAME $DECRYPTION_PASSWORD        
    fi
    unpack_tarball $TARBALL_NAME
else
    # if tarball doesn't exist  download    
    download_tarball $TARBALL_NAME

    if [[ "$TARBALL_NAME" == *.tar.gz.enc ]]; then
        decrypt_tarball $TARBALL_NAME $DECRYPTION_PASSWORD        
    fi
    unpack_tarball $TARBALL_NAME
fi


if [ "$START_SERVICES" -eq 1 ]; then

    if [ -d "gesund_platform" ]; then

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
        # echo "Updating pip packages"
        # pip install -U pip || handle_error "Failed to update pip"
        GESUND_CLI_EXC=$(readlink -m venv/bin/gesund)
        GESUND_CLI_WHEEL=$(ls ./*.whl| head -1)
        echo "Installing gesund platform cli...$GESUND_CLI_WHEEL"
        pip install "$GESUND_CLI_WHEEL" --no-index --find-links wheels || handle_error "Failed to install gesund platform CLI"
        

        # Add alias to .bashrc  
        echo "Successfully installed gesund cli"
        echo "Please note: added following command to .bashrc file"
        echo "alias gesund=$GESUND_CLI_EXC" >> ~/.bashrc 
        alias gesund=$GESUND_CLI_EXC >> ~/.bashrc || handle_error "Failed to add alias to .bashrc"

        LOG_FILE="gesund-installation-cli.log"

        # Signal to restart installation when docker get docker connectivity error
        DOCKER_ERROR="Docker Error while loading platform images"

        # Start gesund initially
        start_gesund

        echo "Waiting for Application startup to complete"
        while ! grep -q "Application startup complete." "$LOG_FILE"; do
            # Check for the Docker error
            if grep -q "$DOCKER_ERROR" "$LOG_FILE"; then
                echo "Detected Docker error in log. Restarting gesund..."
                pkill -f "nohup gesund start"
                start_gesund
            fi
            sleep 1
        done

        echo "Gesund Platform installation done."
        exit

    else
        echo "gesund_platform directory not found"
    fi
fi


