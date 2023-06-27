#!/bin/bash
START_SERVICES=${START_SERVICES:-1}
TARBALL_PATH=${TARBALL_PATH}

AWS_ACCESS_KEY_ID=$S3_ACCESS_ID AWS_SECRET_ACCESS_KEY=$S3_SECRET_KEY AWS_DEFAULT_REGION="eu-west-1" aws s3 cp $TARBALL_PATH ./gesund_platform.tar.gz --sse AES256
if ! [ $? -eq 0 ];
then
	if [ -f "$TARBALL_PATH" ]; then
	echo "$TARBALL_PATH local file detected!"
	# untar the file.
	echo "Unpacking tar.gz file...might take some time, please be patient!"
	tar -xzf $TARBALL_PATH gesund_platform
	else
		exit "TARBALL_PATH neither s3 link nor local path"
	fi
else
	echo "$TARBALL_PATH s3 link downloading done...!"
	# untar the file.
	echo "Unpacking tar.gz file...might take some time, please be patient!"
	tar -xzf gesund_platform.tar.gz gesund_platform
fi


# change directory to gesund_platform
cd gesund_platform || exit "no directory gesund_platform"

echo "Creating python virtual environment."
python3 -m venv venv || exit "Could not create virtual env"


echo "Activating virtual environment"
source venv/bin/activate

GESUND_CLI_EXC=$(readlink -m venv/bin/gesund)
GESUND_CLI_WHEEL=$(ls ./*.whl| head -1)

echo "Updating pip packages"
pip install -U pip || exit "pip unsucessfull"

echo "Installing gesund platform cli...$GESUND_CLI_WHEEL"
python3 -m pip install $GESUND_CLI_WHEEL --no-index --find-links wheels || exit

if ! [ $? -eq 0 ];
then
	echo "Failure to install :("
fi
echo "Successfully installed gesund cli"

echo "Please note: added following command to ./.bashrc file"
echo "alias gesund=$GESUND_CLI_EXC"
alias gesund=$GESUND_CLI_EXC


if [ $START_SERVICES -eq 1 ];
then
	echo "Starting gesund cli with services"
	gesund start --fresh --web || exit "Failed to start gesund server"
	exit
fi

echo "Congrats, gesund platform installation done."
