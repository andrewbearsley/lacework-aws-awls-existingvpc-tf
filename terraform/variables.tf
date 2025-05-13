variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "lacework_integration_name" {
  description = "Name for the Lacework integration"
  type        = string
  default     = "agentless_from_terraform"
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
  default     = "vpc-00271551034f60b74"
}

variable "subnet_id" {
  description = "ID of the existing subnet"
  type        = string
  default     = "subnet-0644a0e25d824bb0f"
}

variable "security_group_id" {
  description = "ID of the existing security group"
  type        = string
  default     = "sg-09ecb33718b0e8867"
}
