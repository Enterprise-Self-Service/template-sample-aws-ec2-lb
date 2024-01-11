terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.10"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      "deployment" = "teraform"
    }
  }
}