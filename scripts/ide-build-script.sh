#!/bin/bash

echo -n "Enter your name and press [ENTER]: "
read name
echo -n "Enter your email address [ENTER]: "
read email
echo

git config --global user.name $name
git config --global user.email $email
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true