terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "epapathom-terraform-state"
    key    = "data-warehouse/terraform.tfstate"
    region = "eu-central-1"
  }
}
