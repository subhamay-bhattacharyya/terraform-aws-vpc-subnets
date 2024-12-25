/*
####################################################################################################
# Terraform Module Configuration
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

# This resource creates a random shuffle of the available AWS availability zones.
# The input is a list of availability zone names obtained from the data source `aws_availability_zones`.
# The `result_count` specifies the number of availability zones to include in the shuffled result.
# The shuffled list can be used to distribute resources across multiple availability zones for high availability.
# --- Random Shuffle
resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = max(length(var.subnet-configuration.public), length(var.subnet-configuration.private))
}

# Creates an AWS Virtual Private Cloud (VPC) with the specified CIDR block.
# Enables DNS hostnames and DNS support within the VPC.
# Tags the VPC with a name that includes the project name and CI build identifier.
#
# Arguments:
#   - var.vpc_cidr: The CIDR block for the VPC.
#   - var.project_name: The name of the project.
#   - var.ci_build: The CI build identifier.
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project-name}-vpc${var.ci-build}"
  }
}

# Creates a AWS Internet Gateway and attaches it to the specified VPC if public cidr is a non empty list.
# 
# Arguments:
#   vpc_id - The ID of the VPC to attach the Internet Gateway to.
# 
# Tags:
#   Name - A name tag for the Internet Gateway, which includes the project name and CI build identifier.
resource "aws_internet_gateway" "igw" {
  count  = length(var.subnet-configuration.public) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project-name}-igw${var.ci-build}"
  }
}


# Creates a public subnets in the specified VPC. The number of subnets created is determined by the length of the public CIDR list.
# 
# Arguments:
# - count: The number of subnets to create, determined by the variable `var.max_subnet_count`.
# - vpc_id: The ID of the VPC where the subnet will be created, obtained from the `aws_vpc.vpc` resource.
# - cidr_block: The CIDR block for the subnet, specified by the `var.public_cidrs` variable.
# - map_public_ip_on_launch: Boolean to indicate whether to assign a public IP address to instances launched in this subnet.
# - availability_zone: The availability zone for the subnet, determined by the `random_shuffle.az_list` resource.
# 
# Tags:
# - Name: A tag to name the subnet, which includes the availability zone index and an optional build identifier from `var.ci_build`.
resource "aws_subnet" "public_subnet" {
  count                   = length(var.subnet-configuration.public)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet-configuration.public[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "${var.project-name}-pub-sn-az-${count.index + 1}${var.ci-build}"
  }
}

# Creates a public route table for the specified VPC. This route table will be used to route traffic to the internet gateway.
# 
# Arguments:
#   vpc_id: The ID of the VPC where the route table will be created.
# 
# Tags:
#   Name: A name tag for the route table, which includes the project name and CI build identifier.
resource "aws_route_table" "public_rt" {
  count  = length(var.subnet-configuration.public)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project-name}-pub-rt-${count.index+1}${var.ci-build}"
  }
}

# Associates the specified subnet with the specified route table.
# This resource creates an association between a subnet and a route table.
# 
# Arguments:
#   count          - The number of subnet associations to create, based on the maximum subnet count.
#   subnet_id      - The ID of the subnet to associate with the route table.
#   route_table_id - The ID of the route table to associate with the subnet.
resource "aws_route_table_association" "public_sn_assoc" {
  count          = length(var.subnet-configuration.public)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[count.index].id
}

# Creates a route in the specified route table that directs traffic destined for
# the specified CIDR block (0.0.0.0/0) to the internet gateway. This effectively
# allows public internet access for resources associated with this route table.
# 
# Arguments:
# - route_table_id: The ID of the route table where the route will be added.
# - destination_cidr_block: The CIDR block that this route applies to.
# - gateway_id: The ID of the internet gateway to which the traffic will be routed.
resource "aws_route" "public_route" {
  count                  = length(var.subnet-configuration.public)
  route_table_id         = aws_route_table.public_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

# Creates a private subnet within a specified VPC. The number of subnets created is determined by the length of the private CIDR list.
# 
# Arguments:
#   count: The number of subnets to create, determined by the variable `var.max_subnet_count`.
#   vpc_id: The ID of the VPC where the subnet will be created, obtained from the `aws_vpc.vpc.id`.
#   cidr_block: The CIDR block for the subnet, specified by the variable `var.private_cidrs` at the index of the current count.
#   map_public_ip_on_launch: Boolean value to specify whether instances launched in this subnet should be assigned a public IP address. Set to `false` for private subnets.
#   availability_zone: The availability zone for the subnet, determined by the `random_shuffle.az_list.result` at the index of the current count.
# 
# Tags:
#   Name: A tag to name the subnet, formatted as "private subnet az-{index + 1}{var.ci_build}".
resource "aws_subnet" "private_subnet" {
  count                   = length(var.subnet-configuration.private)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet-configuration.private[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]


  tags = {
    Name = "${var.project-name}-pvt-sn-az-${count.index + 1}${var.ci-build}"
  }
}

# Creates a private route table for the specified VPC.
# 
# Arguments:
#   vpc_id - The ID of the VPC where the route table will be created.
# 
# Tags:
#   Name - A name tag for the route table, which includes the project name and CI build identifier.
resource "aws_route_table" "private_rt" {
  count  = length(var.subnet-configuration.private)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project-name}-pvt-rt-${count.index+1}${var.ci-build}"
  }
}

# Associates a private subnet with a route table.
# 
# Arguments:
#   count          - The number of subnet associations to create, based on the variable `max_subnet_count`.
#   subnet_id      - The ID of the private subnet to associate with the route table, retrieved from the list of private subnets.
#   route_table_id - The ID of the private route table to associate with the subnet.
resource "aws_route_table_association" "private_sn_assoc" {
  count          = length(var.subnet-configuration.private) 
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

# Creates an AWS Network ACL (NACL) resource.
# 
# This resource defines a network ACL for the specified VPC.
# 
# Arguments:
# - vpc_id: The ID of the VPC where the network ACL will be created.
# 
# Ingress Rules:
# - protocol: The protocol number. `-1` means all protocols.
# - rule_no: The rule number for the ingress rule.
# - action: The action to take (allow or deny).
# - cidr_block: The CIDR block to allow or deny traffic from.
# - from_port: The starting port for the range.
# - to_port: The ending port for the range.
# 
# Egress Rules:
# - protocol: The protocol number. `-1` means all protocols.
# - rule_no: The rule number for the egress rule.
# - action: The action to take (allow or deny).
# - cidr_block: The CIDR block to allow or deny traffic to.
# - from_port: The starting port for the range.
# - to_port: The ending port for the range.
# 
# Tags:
# - Name: A name tag for the network ACL, which includes the project name and CI build identifier.
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project-name}-nacl${var.ci-build}"
  }
}

# Associates a network ACL with public subnets.
# 
# Arguments:
#   count          - The number of subnet associations to create, based on the variable `max_subnet_count`.
#   network_acl_id - The ID of the network ACL to associate with the subnets.
#   subnet_id      - The ID of the public subnet to associate with the network ACL, indexed by the count.
resource "aws_network_acl_association" "nacl_association_pub" {
  count          = length(var.subnet-configuration.public)
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Associates a network ACL with private subnets.
# 
# Arguments:
#   count          - The number of subnet associations to create, based on the maximum subnet count.
#   network_acl_id - The ID of the network ACL to associate with the subnets.
#   subnet_id      - The ID of the private subnet to associate with the network ACL.
#
# Resources:
#   aws_network_acl_association.nacl_association_pvt - Creates an association between the specified network ACL and private subnets.
resource "aws_network_acl_association" "nacl_association_pvt" {
  count          = length(var.subnet-configuration.private)
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}