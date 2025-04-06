terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92.0"
    }
  }
  backend "s3" {
     bucket = "soumya-tf-dev-remote"
    key    = "expense-dev-eks-ecr-cicd" #you should have unique keys with i the bucket , same keys should not useed in other repos or tf projects
    region = "us-east-1"
    dynamodb_table = "soumya-tf-dev-remote-lock"
  }

}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}