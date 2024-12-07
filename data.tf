/*
####################################################################################################
# Terraform Data Blocks Configuration
#
# Description: This module creates a VPC Network (VPC/Subnets/Internet Gateway/NACL/NatGateway)
#              using Terraform.
#
# Author: Subhamay Bhattacharyya
# Created: 18-Nov-2024 
# Version: 1.0
#
####################################################################################################
*/

# AWS Region and Caller Identity
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}