terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }

  required_version = ">= 1.4.2"
}

provider "aws" {
  profile = "moodle"
  region  = "sa-east-1"
}