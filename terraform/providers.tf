terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}

# Billing metrics only live in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  profile = "default"
}