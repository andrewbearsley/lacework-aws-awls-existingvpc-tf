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

Use these AWS CLI commands to identify your existing resources for deployment:

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

## Deploying the Terraform Configuration

```bash
# In the terraform directory where main.tf is located
terraform init
terraform plan
terraform apply
```

