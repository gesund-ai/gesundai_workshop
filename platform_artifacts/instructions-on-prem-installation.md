# Gesund Platform Installation Guide

Welcome to the Gesund Platform Installation Guide. This guide will walk you through the simplified installation process of the Gesund Platform on your server. Please make sure to meet the prerequisites before proceeding.

## Prerequisites

Before you begin, ensure you have the following prerequisites:

1. Server Access: You need SSH access to the server where you want to install the Gesund Platform.

2. Dependencies: The installation script will attempt to install these dependencies, but you can install them manually if needed:

    - Docker
    - Docker Compose
    - Python 3
    - Python 3 Virtual Environment (python3-venv)
    - Curl
    - OpenSSL
    - Tar
    - libgl1 (required for OpenCV)

3. Decryption Password: You will receive a decryption password from the Gesund Team to decrypt the installation tarball.

4. Credentials: The Gesund Team will provide the necessary credentials for platform access.

## Installation Steps

### 1. Connect to the Server

Use SSH or your preferred method to connect to your server. Replace `username` and `yourserver` with your server's username and address.

    ```bash
    ssh username@yourserver
    ```

### 2. Create a Deployment Directory

Create a deployment directory on your server:

```bash
mkdir deployment/ && cd deployment
```

### 3. Download the Installation Script

You can either obtain the installation script from the Gesund team directly or download it from the publicly accessible URL:

#### Option 1: Gesund Team Provides the Script

If the Gesund team provides you with the installation script directly, you can skip the download step.

#### Option 2: Download from Public URL

To download the installation script from the public URL, use the following command:

```bash
curl -o gesund-platform-installer.sh https://raw.githubusercontent.com/gesund-ai/gesundai_workshop/main/platform_artifacts/gesund-platform-installer.sh

```

### 4. Execute the Installation Script

Execute the `gesund-platform-installer.sh` script. This command will automatically:

- Download the encrypted tarball.
- Decrypt the tarball using the provided password.
- Install the Gesund Platform.

```bash
./gesund-platform-installer.sh --tarball gesund_platform*.tar.enc --decryption-password PASSWORD  --start-services
```
Replace `gesund_platform*.tar.enc` with the actual tarball filename and `PASSWORD` with the provided decryption password.

Run the `gesund-platform-installer.sh` script and wait for the installation to finish. 


Optionally, the user can provide only the tarball name already decrypted. In this case the `--decryption-password` parameter can be ommited:
```bash
./gesund-platform-installer.sh --tarball gesund_platform*.tar  --start-services
```

**Note:**
The script first checks if the file is already present in your directory. If it's not found, it proceeds to download the file. However, if the file is already present, it immediately initiates the installation process.

####  Command-line Options

The script supports the following command-line options:

- `-t, --tarball NAME`: Specifies the name of the encrypted tarball on S3 (required).
- `-d, --decryption-password PASSWORD`: Specifies the decryption password (Optional).
-  `-s, --start-services`:  Start platform services after installation (optional)
- `-h, --help`: Shows the help message and exits.

### 5. Check Running Services

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


### 6. Access the Platform

Open a web browser and access the Gesund Platform using the public IP address of your server. Replace `SERVER_PUBLIC_IP` with the actual public IP address.

```bash
http://SERVER_PUBLIC_IP
```

#### Optional: Port Forwarding for Local Access

If you'd like to access the Gesund Platform from your local machine without exposing the server to the public internet, you can use SSH port forwarding. 

Run the following command on your local machine:

```shell
ssh -L 8080:SERVER_PUBLIC_IP:80 YOUR_SSH_USERNAME@YOUR_SERVER_IP
```

Replace `YOUR_SSH_USERNAME` with your SSH username and `YOUR_SERVER_IP` with your server's IP address.

After running this command, you can access the Gesund Platform in your local web browser by going to:

```plaintext
http://localhost:8080
```

This will forward the traffic from your local machine's port 8080 to your server's port 80, allowing you to access the platform securely from your local environment.

Please note that this option requires an active SSH session and terminal window to be kept open. You can close the SSH session by pressing `Ctrl+C` in the terminal.

Remember to replace placeholders like `SERVER_PUBLIC_IP`, `YOUR_SSH_USERNAME`, and `YOUR_SERVER_IP` with actual values.



### 7. Log In to the Platform

Enter the provided credentials to log in to the Gesund Platform:

- Username: admin@gesund.ai
- Password: [Instructions below]

#### Configure admin password
Gesund AI uses the instance ID of your server as a password. In your server terminal run the command:

```bash
sudo dmidecode | grep UUID
```

Example of expected results:
```
UUID: 090556DA-D4FA-764F-A9F1-63614EDA019A
```

The UUID `090556DA-D4FA-764F-A9F1-63614EDA019A` is the password to access the platform as admin. 

Go the platform and insert the credentials. 

### 8. Container Sizes

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



### Conclusion

Congratulations, you have successfully installed the Gesund Platform on your server! You are now ready to explore and utilize its powerful features for your healthcare projects.

If you encounter any issues during the installation process or have questions about the Gesund Platform, don't hesitate to reach out to the Gesund Team for assistance. We're here to help you ensure a smooth installation and answer any queries you may have.

