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
  region = "ap-southeast-2"
}

// Create global resources, includes lacework cloud integration.
// This will also create regional resources too.
// If scanning should occur on multiple regions then refer to the 'default' example.
module "lacework_aws_agentless_scanning_singleregion" {
  source = "lacework/agentless-scanning/aws"
  version = "~> 0.10" 

  global                    = true
  regional                  = true
  lacework_integration_name = "agentless_from_terraform"

  // This expects the VPC to have a route to the internet.
  // There are options in the terraform here to create an IGW if needed.
  use_existing_vpc            = true
  use_internet_gateway        = false
  vpc_id                      = "vpc-00271551034f60b74"
  use_existing_security_group = true
  security_group_id           = "sg-09ecb33718b0e8867"

  // Only a single subnet is needed.
  use_existing_subnet = true
  subnet_id           = "subnet-0644a0e25d824bb0f"
}
