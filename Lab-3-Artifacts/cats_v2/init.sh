#!/bin/bash

BUCKET_CATS_DOGS="catsndogs-assets/cats-images"
BUCKET_UNICORN="catsndogs-assets/unicorns-images"

SECRET_PATH=$(aws ssm get-parameters --region $REGION --names $PARAMETER_STORE_NAME --with-decryption --output text | awk '{print $4}')

if [ "$SECRET_PATH" != "" ]; then echo "secret='"$SECRET_PATH"';" >> /var/www/html/app.js; fi

TASK_ID=$(curl http://172.17.0.1:51678/v1/tasks | grep "\"Arn\"" | awk -F"task/" '{print $2}' | awk -F"\"" '{print $1}') #get task id

if [ "$TASK_ID" != "" ]; then echo "taskId='"$TASK_ID"';" >> /var/www/html/app.js; fi # output task id

/usr/local/bin/aws --region $REGION s3 cp s3://$BUCKET_CATS_DOGS /var/www/html/ --recursive

#cp images to backup location so the API can reset them later if needed/requested:
mkdir /var/www/html/backup-images
cp /var/www/html/*.jpg  /var/www/html/backup-images/
# copy unicorn images
if [ "$SECRET_PATH" != "" ]; then
mkdir /var/www/html/$SECRET_PATH
/usr/local/bin/aws --region $REGION s3 cp s3://$BUCKET_UNICORN /var/www/html/$SECRET_PATH --recursive
fi
