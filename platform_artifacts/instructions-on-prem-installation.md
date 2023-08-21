# Gesund Platform Installation Guide

This guide will walk you through the simplified installation process of the Gesund Platform.

## Prerequisites

- Access to a server with SSH or your preferred remote access method.
- Docker installed and configured on your server.
- The Gesund team should have provided you with the necessary decryption password and credentials to log in to the Gesund Platform.

## Installation Steps

1. **Connect to the Server**

    Use SSH or your preferred method to connect to your server. Replace `username` and `yourserver` with your server's username and address.

    ```bash
    ssh username@yourserver
    ```

2. **Create a Deployment Directory**

    Create a deployment directory on your server:

    ```bash
    mkdir deployment/ && cd deployment
    ```

3. **Download the Installation Script**

    You can either obtain the installation script from the Gesund team directly or download it from the publicly accessible URL:

    **Option 1: Gesund Team Provides the Script**

    If the Gesund team provides you with the installation script directly, you can skip the download step.

    **Option 2: Download from Public URL**

    To download the installation script from the public URL, use the following command:

    ```bash
    curl -o gesund-platform-installer.sh https://gesund-platform-releases.s3.amazonaws.com/gesund-platform-installer.sh
    ```

4. **Execute the Installation Script**

    Execute the `gesund-platform-installer.sh` script. This command will automatically:

    - Download the encrypted tarball.
    - Decrypt the tarball using the provided password.
    - Install the Gesund Platform CLI.

    ```bash
    ./gesund-platform-installer.sh --tarball gesund_platform*.tar.enc --decryption-password PASSWORD 
    ```
    Replace `gesund_platform*.tar.enc` with the actual tarball filename and `PASSWORD` with the provided decryption password.

    Run the `gesund-platform-installer.sh` script and wait for the installation to finish. 


    ###  Command-line Options

    The script supports the following command-line options:

    - `-t, --tarball NAME`: Specifies the name of the encrypted tarball on S3 (required).
    - `-d, --decryption-password PASSWORD`: Specifies the decryption password (required).
    - `-h, --help`: Shows the help message and exits.

    
    

5. **Access the Platform**

    Open a web browser and access the Gesund Platform using the public IP address of your server. Replace `SERVER_PUBLIC_IP` with the actual public IP address.

    ```
    http://SERVER_PUBLIC_IP
    ```

6. **Check Running Services**

    To check if the services are running, run the following command:

    ```bash
    docker ps
    ```

    You should see the following service containers running:

    - mlutility
    - gesund-docs
    - web-client
    - web-server
    - web_bin_certbot_1
    - db_manager
    - nodejs-tool
    - mongodb
    - rabbitmq

7. **Log In to the Platform**

    Enter the provided credentials to log in to the Gesund Platform:

    - Username: admin@gesund.ai
    - Password: [Contact the Gesund team for the password]

8. **Container Sizes**

    Here are the container sizes for various components of the Gesund Platform:

    ```
    gesundai/gesund-app            259MB
    gesundai/gesund-app            179MB
    prediction                    2.18GB
    mlutility                     8.62GB
    validation                    2.56GB
    db_manager                    6.62GB
    autodeploy                    1.93GB
    nodejs-tool                    536MB
    gesundai/gesund-docs           837MB
    certbot/certbot               96.6MB
    rabbitmq                       270MB
    mongo                          696MB
    ```
