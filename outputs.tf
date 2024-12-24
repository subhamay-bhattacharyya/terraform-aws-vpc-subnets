/*
####################################################################################################
# Terraform AWS Networking Outputs Configuration
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

# This output provides the list of Availability Zones.
# It retrieves the value from the random_shuffle resource named az_list.
output "az-list" {
  description = "The list of Availability Zones"
  value       = random_shuffle.az_list
}

# This output block defines an output variable named "vpc-id".
# It provides the ID of the VPC created by the aws_vpc resource.
# The value attribute references the ID of the VPC from the aws_vpc resource.
output "vpc-id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}


# This output provides the configuration details for both public and private subnets.
# The value is derived from the variable `subnet-configuration`.
# It can be used to reference subnet settings in other modules or resources.
output "subnet-configuration" {
  description = "Configuration for public and private subnets"
  value       = var.subnet-configuration
}


# This output variable provides the ID of the Internet Gateway created by the module.
output "internet-gateway-id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.igw[0].id, "no internet gateway")
}


# This output provides the IDs of the public subnets created by the module.
output "public-subnet-ids" {
  description = "The IDs of the public subnets"
  value       = try(aws_subnet.public_subnet[*].id, "no public subnets")
}

# This output variable provides the IDs of the private subnets created by the module.
# It is useful for referencing the private subnets in other parts of your Terraform configuration
# or in other modules that depend on this networking module.
output "private-subnet-ids" {
  description = "The IDs of the private subnets"
  value       = try(aws_subnet.private_subnet[*].id, "no private subnets")
}

# This output block defines an output variable named "public-route-table-id".
# It provides the ID of the public route table created by the aws_route_table resource.
# The description attribute gives a brief explanation of the output.
# The value attribute references the ID of the first public route table in the aws_route_table.public_rt list.
output "public-route-table-ids" {
  description = "The IDs of the public route tables"
  value       = try(aws_route_table.public_rt[*].id, "no public route table")
}

# This output variable provides the ID of the private route table.
# It is useful for referencing the private route table in other modules or resources.
# The value is obtained from the first element of the aws_route_table.private_rt array.
output "private-route-table-ids" {
  description = "The IDs of the private route tables"
  value       = try(aws_route_table.private_rt[*].id, "no private route table")
}

# This output block defines an output variable named "network-acl-id".
# It provides the ID of the Network ACL created by the aws_network_acl resource.
# The description attribute gives a brief explanation of the output variable.
# The value attribute assigns the ID of the Network ACL to the output variable.
output "network-acl-id" {
  description = "The ID of the Network ACL"
  value       = aws_network_acl.nacl.id
}

# This output provides the IDs of the public network ACL associations.
# It retrieves the IDs from the aws_network_acl_association resource
# for the public network ACL associations.
output "public-nacl-ids" {
  description = "The IDs of the public network ACL associations"
  value       = aws_network_acl_association.nacl_association_pub[*].id
}

# This output variable provides the IDs of the private network ACL associations.
# It retrieves the IDs from the aws_network_acl_association resource for private subnets.
output "private-nacl-ids" {
  description = "The IDs of the private network ACL associations"
  value       = aws_network_acl_association.nacl_association_pvt[*].id
}