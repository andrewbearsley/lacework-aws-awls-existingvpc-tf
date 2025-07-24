# Lacework Agentless Scanning - Existing VPC - Single Account - Terraform

## Purpose

This project is for the purpose of creating Lacework FortiCNAPP AWS agentless workload scanning, using an existing VPC, deployed via terraform.

## References

https://github.com/lacework/terraform-aws-agentless-scanning/tree/main/examples/single-account-existing-vpc-networking

## Prerequisites

- AWS Account
- Lacework Account
- Lacework CLI
- Terraform CLI
- AWS CLI

## AWS CLI Setup

```bash
export AWS_ACCOUNT_ID=[Your AWS Account ID] && \
export AWS_REGION=[Your AWS Region] && \
export AWS_PROFILE=[Your AWS Profile] && \
export AWS_PAGER=""

# example
export AWS_ACCOUNT_ID=631604671854 && \
export AWS_REGION=ap-southeast-2 && \
export AWS_PROFILE=sandbox-admin && \
export AWS_PAGER=""
```

## Lacework CLI Setup

```bash
# Install Lacework CLI 
# Docs https://docs.fortinet.com/document/lacework-forticnapp/latest/cli-reference/68020/get-started-with-the-lacework-forticnapp-cli

# Get Lacework API Key
# Settings > API keys > Add New

# Configure Lacework CLI with API key
lacework configure
```

## Terraform Setup
```bash
# Install terraform
# https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
```

## Finding Required AWS Resources (VPC, Subnet, Security Group)

You can identify your existing AWS resources using either the automated script (recommended) or manual AWS CLI commands.

### Option 1: Automated Script (Recommended)

Use the provided script to automatically discover and configure your AWS resources:

```bash
# Run the AWS resource lookup script
./scripts/aws-resource-lookup.sh
```

This script will:
- Check for required AWS environment variables
- List available VPCs and auto-select if only one exists
- Display subnets for your selected VPC
- Show security groups with HTTPS egress status
- Auto-select security groups if only one exists
- Verify security group rules for outbound HTTPS access
- Provide the exact values to update in `terraform/terraform.tfvars`

### Option 2: Manual AWS CLI Commands

Alternatively, you can manually identify your existing resources using these AWS CLI commands:

### 1. List VPCs in a region

```bash
# List all VPCs in your region
aws ec2 describe-vpcs --query "Vpcs[*].[VpcId,Tags[?Key=='Name'].Value|[0],CidrBlock]" --output table
```

### 2. Find subnets for a specific VPC

```bash
# Replace vpc-xxxxxxxx with your VPC ID
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxx" \
  --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock]" --output table
```

### 3. Find security groups for a specific VPC

```bash
# Replace vpc-xxxxxxxx with your VPC ID
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-xxxxxxxx" \
  --query "SecurityGroups[*].[GroupId,GroupName]" --output table
```

### 4. Verify security group allows outbound HTTPS traffic

```bash
# Replace sg-xxxxxxxx with your security group ID
aws ec2 describe-security-group-rules --filter "Name=group-id,Values=sg-xxxxxxxx"
```

Look for an outbound rule (IsEgress: true) that allows HTTPS (port 443) traffic or all traffic (IpProtocol: "-1").

After identifying your resources manually, update the `terraform/terraform.tfvars` file with your values:

```hcl
aws_region        = "your-region"
vpc_id            = "vpc-xxxxxxxx"
security_group_id = "sg-xxxxxxxx"
subnet_id         = "subnet-xxxxxxxx"
```

## Deploying the Terraform Configuration

```bash
# In the terraform directory where main.tf is located
# Update the terraform/terraform.tfvars file with your AWS resource values:
# aws_region        = "your-region"
# vpc_id            = "vpc-xxxxxxxx"
# security_group_id = "sg-xxxxxxxx"
# subnet_id         = "subnet-xxxxxxxx"

terraform init
terraform plan
terraform apply
```

