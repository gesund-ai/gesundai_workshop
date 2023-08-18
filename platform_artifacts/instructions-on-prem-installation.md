1. Connect to the server using SSH or any preferred method.

    
    ```
    ssh username@yourserver
    ```
    
2. Create a deployment directory
    
    ```
    mkdir deployment/ && cd deployment
    ```
    
3. Download the tarball from S3
    
    ```
    
    aws s3 cp s3://PATH/TO/TARBALL YOUR/LOCAL/PATH --sse AES256
    ```
    
4. Download the installation script
    
    ```
    aws s3 cp s3://PATH/TO/INSTALLATION_SCRIPT YOUR/LOCAL/PATH
    ```
5. Decrypt the tarball
    Use the password provided by Gesund team
    ```
    openssl  aes-256-cbc -d -in gesund_platform*.tar.enc -out gesund_platform*.tar
    ```

6. Execute the `install.sh` script with the appropriate tarball path.
    
    ```
    TARBALL_PATH="/path/to/tarball/" ./install.sh
    
    ```
    
    This command will install the platform CLI.
    
7. Optionally, you can start the services directly by setting the `START_SERVICES` environment variable and skipping step 4.
    
    ```
    START_SERVICES=1 TARBALL_PATH="/path/to/tarball/" ./install.sh
    
    ```
    
8. Execute the `gesund-cli` command.
    
    ```
    gesund start --fresh --web
    
    ```
    
9. Open a web browser and access the platform using the public IP address. (e.g)
    
    ```
    <http://SERVER_PUBLIC_IP>
    
    ```
    
    Replace `SERVER_PUBLIC_IP` with the actual public IP address of the server.
    
10. Check if the services are running. Run the following command:
    
    ```
    docker ps
    ```
    
    You should be able the following service container running:
    
    - mlutility
    - gesund-docs
    - web-client
    - web-server
    - web_bin_certbot_1
    - db_manager
    - nodejs-tool
    - mongodb
    - rabbitmq
11. Enter the provided credentials to log in to the platform.
    - Username: [admin@gesund.ai](mailto:admin@gesund.ai)
    - Password:
    
    The password can be obtained by getting the instance ID e.g
    
    ```
    sudo dmidecode | grep UUID
    > UUID: 123a5b-293c-41ec-aa4e-9ff04f99f3e7
    ```
12. Listed below are the container sizes for various components of the "gesund" services:

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