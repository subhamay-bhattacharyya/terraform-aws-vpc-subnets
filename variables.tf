/*
####################################################################################################
# Terraform AWS Networking Variables Configuration
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

######################################## Project Name ##############################################
variable "project-name" {
  description = "The name of the project"
  type        = string
  default     = "your-project-name"
}

######################################## Network Resources #########################################
variable "vpc-cidr" {
  description = "VPC CIDR range of IP addresses."
  type        = string
  default     = "10.0.0.0/16"
}

# -- Dns Hostnames
variable "enable-dns-hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

# -- Dns Support
variable "enable-dns-support" {
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = true
}


variable "subnet-configuration" {
  description = "Configuration for public and private subnets"
  type = object({
    public  = list(string)
    private = list(string)
  })
  default = {
    public  = []
    private = []
  }
}
######################################## GitHub ####################################################
# The CI build string
variable "ci-build" {
  description = "The CI build string"
  type        = string
  default     = ""
}