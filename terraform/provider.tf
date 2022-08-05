terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "test_instance" {
  ami           = "ami-0f5094faf16f004eb"
  instance_type = "t2.medium"

  tags = {
    Name = "test_instance"
  }
}
