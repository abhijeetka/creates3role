
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

}


provider "aws" {
  region = var.aws_region
#  assume_role {
#    role_arn    = var.assume_role_name
#    external_id = "my_external_id"
#  }
}


terraform {
  backend "s3" {
    bucket  = "terraform-global-state-techstack-acc"
    region  = "us-east-1"
    encrypt = true
    key     = "tf-awss3-bucket-role/terraform.tfstate"
  }
}

resource "aws_iam_policy" "aws-s3-policy" {
  name        = "s3-bucket-read-acess-policy"
  path        = "/"
  description = "s3 bucket read access policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicRead",
        "Effect": "Allow",
        "Principal": "",
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:List*"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "s3-read-all" {
  name = var.role_name
}

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role       = aws_iam_role.s3-read-all.name
  policy_arn = aws_iam_policy.aws-s3-policy.arn
}


###### Variables #######

variable "aws_region" {
  default = "us-east-1"
}

variable "role_name" {
  default = "s3-grant-all-role"
}

