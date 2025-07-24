#!/bin/bash

# AWS Resource Lookup Script for Lacework Agentless Scanning
# This script helps identify AWS resources needed for Lacework Agentless Workload Scanning deployment

# Exit on error
set -e

# Text formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display section headers
section() {
  echo -e "\n${BOLD}${BLUE}$1${NC}\n"
}

# Function to display prompts
prompt() {
  echo -e "${BOLD}${YELLOW}$1${NC}"
}

# Function to display success messages
success() {
  echo -e "${GREEN}$1${NC}"
}

# Check if required tools are installed
if ! command -v aws &> /dev/null; then
  echo "Error: AWS CLI is not installed. Please install it first."
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it first with 'brew install jq'."
  exit 1
fi

# Setup AWS environment variables
setup_aws_env() {
  section "AWS CLI Setup"
  
  # Prompt for AWS Account ID if not set
  if [ -z "$AWS_ACCOUNT_ID" ]; then
    prompt "Enter your AWS Account ID:"
    read AWS_ACCOUNT_ID
    export AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID
  fi
  
  # Prompt for AWS Region if not set
  if [ -z "$AWS_REGION" ]; then
    prompt "Enter your AWS Region (e.g., ap-southeast-2):"
    read AWS_REGION
    export AWS_REGION=$AWS_REGION
  fi
  
  # Prompt for AWS Profile if not set
  if [ -z "$AWS_PROFILE" ]; then
    prompt "Enter your AWS Profile:"
    read AWS_PROFILE
    export AWS_PROFILE=$AWS_PROFILE
  fi
  
  # Disable AWS pager
  export AWS_PAGER=""
  
  echo "AWS Environment Variables:"
  echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID"
  echo "AWS_REGION=$AWS_REGION"
  echo "AWS_PROFILE=$AWS_PROFILE"
  echo "AWS_PAGER=$AWS_PAGER"
  
  success "AWS CLI setup complete!"
}

# List VPCs in the region
list_vpcs() {
  section "1. Listing VPCs in $AWS_REGION"
  
  # Get VPCs and save to variable
  VPC_LIST=$(aws ec2 describe-vpcs --query "Vpcs[*].[VpcId,Tags[?Key=='Name'].Value|[0],CidrBlock]" --output json)
  
  # Display VPCs in table format
  aws ec2 describe-vpcs --query "Vpcs[*].[VpcId,Tags[?Key=='Name'].Value|[0],CidrBlock]" --output table
  
  # Count number of VPCs
  VPC_COUNT=$(echo $VPC_LIST | jq '. | length')
  
  # If only one VPC exists, select it automatically
  if [ "$VPC_COUNT" -eq 1 ]; then
    VPC_ID=$(echo $VPC_LIST | jq -r '.[0][0]')
    echo "Only one VPC found. Automatically selecting: $VPC_ID"
  else
    prompt "Enter the VPC ID you want to use (vpc-xxxxxxxx):"
    read VPC_ID
  fi
  
  export VPC_ID=$VPC_ID
  success "VPC ID set to: $VPC_ID"
}

# Find subnets for the selected VPC
find_subnets() {
  section "2. Finding subnets for VPC: $VPC_ID"
  aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock]" --output table
  
  prompt "Enter the Subnet ID you want to use (subnet-xxxxxxxx):"
  read SUBNET_ID
  export SUBNET_ID=$SUBNET_ID
  
  success "Subnet ID set to: $SUBNET_ID"
}

# Find security groups for the selected VPC
find_security_groups() {
  section "3. Finding security groups for VPC: $VPC_ID"
  aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" \
    --query "SecurityGroups[*].[GroupId,GroupName]" --output table
  
  prompt "Enter the Security Group ID you want to use (sg-xxxxxxxx):"
  read SECURITY_GROUP_ID
  export SECURITY_GROUP_ID=$SECURITY_GROUP_ID
  
  success "Security Group ID set to: $SECURITY_GROUP_ID"
}

# Verify security group allows outbound HTTPS traffic
verify_security_group() {
  section "4. Verifying security group allows outbound HTTPS traffic"
  aws ec2 describe-security-group-rules --filter "Name=group-id,Values=$SECURITY_GROUP_ID"
  
  echo ""
  echo "Please verify that the security group has an outbound rule (IsEgress: true)"
  echo "that allows HTTPS (port 443) traffic or all traffic (IpProtocol: \"-1\")."
  
  prompt "Does the security group have the required outbound rule? (y/n):"
  read CONFIRM
  if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "Please update your security group to allow outbound HTTPS traffic and try again."
    exit 1
  fi
  
  success "Security group verification complete!"
}

# Display summary of selected resources
display_summary() {
  section "Resource Summary"
  echo "VPC ID: $VPC_ID"
  echo "Subnet ID: $SUBNET_ID"
  echo "Security Group ID: $SECURITY_GROUP_ID"
  
  echo ""
  echo "You can now use these values in your Terraform configuration."
  echo "Update the terraform/main.tf file with these values."
  
  success "Resource lookup complete!"
}

# Main execution
main() {
  echo -e "${BOLD}Lacework Agentless Scanning - AWS Resource Lookup${NC}"
  echo "This script will help you identify the AWS resources needed for deployment."
  echo ""
  
  setup_aws_env
  list_vpcs
  find_subnets
  find_security_groups
  verify_security_group
  display_summary
  
  section "Next Steps"
  echo "1. Navigate to the terraform directory"
  echo "2. Run: terraform init"
  echo "3. Run: terraform plan"
  echo "4. Run: terraform apply"
}

# Run the script
main
