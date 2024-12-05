provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = "5.48.0"
  }
}