terraform {
  required_providers {
    lacework = {
      source = "lacework/lacework"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "lacework" {}

provider "aws" {
  // Use the variable for the region
  region = var.aws_region
}

module "lacework_aws_agentless_scanning_singleregion" {
  source  = "lacework/agentless-scanning/aws"
  version = "~> 0.10"

  global                  = true
  regional                = true
  lacework_integration_name = var.lacework_integration_name

  // Use variables for your AWS resources
  use_existing_vpc        = true
  use_internet_gateway    = false
  vpc_id                  = var.vpc_id
  use_existing_security_group = true
  security_group_id       = var.security_group_id
  use_existing_subnet     = true
  subnet_id               = var.subnet_id
}