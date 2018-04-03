#!/bin/bash

echo "Configuring Git ..."
echo -n "Enter your name and press [ENTER]: "
read name
echo -n "Enter your email address [ENTER]: "
read email
echo

git config --global user.name $name
git config --global user.email $email
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

cd /tmp
mkdir ./dogs

#git clone https://github.com/MitchyBAwesome/dogs.git

wget https://raw.githubusercontent.com/MitchyBAwesome/amazon-ecs-catsndogs-workshop/master/Lab-6-Artifacts/dogs/Dockerfile -O ./dogs/Dockerfile
wget https://raw.githubusercontent.com/MitchyBAwesome/amazon-ecs-catsndogs-workshop/master/Lab-6-Artifacts/dogs/README.md -O ./dogs/README.md
wget https://raw.githubusercontent.com/MitchyBAwesome/amazon-ecs-catsndogs-workshop/master/Lab-6-Artifacts/dogs/buildspec.yml -O ./dogs/buildspec.yml
wget https://raw.githubusercontent.com/MitchyBAwesome/amazon-ecs-catsndogs-workshop/master/Lab-6-Artifacts/dogs/index.html -O ./dogs/index.html
wget https://raw.githubusercontent.com/MitchyBAwesome/amazon-ecs-catsndogs-workshop/master/Lab-6-Artifacts/dogs/nginx.conf -O ./dogs/nginx.conf

cp /tmp/dogs/* ~/environment/dogs

cd ~/environment/dogs
