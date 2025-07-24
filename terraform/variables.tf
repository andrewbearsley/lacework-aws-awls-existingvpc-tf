variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the existing VPC to use."
  type        = string
}

variable "security_group_id" {
  description = "The ID of the existing security group to use."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the existing subnet to use."
  type        = string
}

variable "lacework_integration_name" {
  description = "A unique name for the Lacework integration."
  type        = string
  default     = "agentless_from_terraform"
}