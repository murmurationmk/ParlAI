terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

    backend "s3"{
        bucket= "parlaistate"
        key = "terraform.tfstate"
        region="us-east-1"
        dynamodb_table="statelock-tf"
    }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
  tags = {
    Project = "ParlAI"
  }
}

resource "aws_iam_policy" "s3_full_access" {
  name   = "s3_full_access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Resource = "*"
        Effect   = "Allow"
      },
    ]
  })
  tags = {
    Project = "ParlAI"
  }
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_access_role.name

  tags = {
    Project = "ParlAI"
  }
}

resource "aws_instance" "parlai-instance" {
  ami                  = data.aws_ami.linux-ami.id
  instance_type        = "t2.2xlarge"
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name
  user_data            = file("bootstrap.sh")
  root_block_device {
    volume_size        = 40
  }

  tags = {
    Project = "ParlAI"
    Name    = "parlai-instance"
  }
}

#Bucket to host static website
resource "aws_s3_bucket" "parlai-site" {
  bucket = "parlai-site"
  
  tags = {
    Project = "ParlAI"
  }
}
resource "aws_vpc" "parlai_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Project = "ParlAI"
  }
}

resource "aws_subnet" "parlai_subnet" {
  vpc_id            = aws_vpc.parlai_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Project = "ParlAI"
  }
}




