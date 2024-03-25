#!/bin/bash

# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo systemctl enable docker

#Add ec2-user to docker group
sudo usermod -a -G docker ec2-user
newgrp docker

#Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Clone Parl AI git repo, copy website source code to s3
sudo yum install git -y
git clone https://github.com/facebookresearch/ParlAI.git ~/ParlAI
cd ~/ParlAI
sed -i 's/openai<=0.27.7/openai<=1.10.0/g' ~/ParlAI/requirements.txt
aws s3 sync ~/ParlAI/website s3://parlai-site

#Create and activate venv, setup ParlAI
python3 -m venv venv
source venv/bin/activate
venv/bin/pip install --upgrade pip setuptools wheel
venv/bin/pip install parlai