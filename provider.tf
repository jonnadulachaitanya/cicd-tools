terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0"
    }
  }

  backend "s3" {
    bucket         = "chaitanya-project-remote-state-bucket-dev"
    key            = "expense_cicd"
    region         = "us-east-1"
    dynamodb_table = "chaitanya-locking-dev"
  }
}

provider "aws" {
  region = "us-east-1"
}
