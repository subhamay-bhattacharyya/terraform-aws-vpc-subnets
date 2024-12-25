![](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;![](https://img.shields.io/github/last-commit/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;![](https://img.shields.io/github/release-date/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;![](https://img.shields.io/github/repo-size/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;![](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;[](https://img.shields.io/github/issues/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;![](https://img.shields.io/github/languages/top/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;![](https://img.shields.io/github/commit-activity/m/subhamay-bhattacharyya/terraform-aws-vpc-subnets)&nbsp;![](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/12772af0a4876ab905185d75933392fb/raw/terraform-aws-vpc-subnets.json?)

## Terraform AWS VPC-Subnets Module

This repository contains a Terraform module for creating and managing AWS VPC networks, including subnets, Internet Gateways, Network ACLs, and NAT Gateways.

### Usage

* Terraform module to create VPC subnets.
* Module source: app.terraform.io/subhamay-bhattacharyya/vpc-subnets/aws
* Version: 1.0.0

### Required Inputs:
- `project-name`: The name of the project.
- `vpc-cidr`: The CIDR block for the VPC (e.g., "10.0.0.0/16").
- `enable-dns-hostnames`: Boolean to enable/disable DNS hostnames in the VPC.
- `enable-dns-support`: Boolean to enable/disable DNS support in the VPC.
- `subnet-configuration`: A map defining the CIDR blocks for public and private subnets.
- `ci-build`: A string representing the CI build identifier.

### Example Usage:

```hcl
module "vpc_subnets" {
  source  = "app.terraform.io/subhamay-bhattacharyya/vpc-subnets/aws"
  version = "1.0.0"

  project-name             = "your-project-name"
  vpc-cidr                 = "your-vpc-cidr-range"
  subnet-configuration     = "your-subnet-configuration"
  ci-build                 = "your-ci-build-string"
}
```

### Subnet configuration

##### Configure the numbers of public and private subnets using the variables.

```hcl
public-subnet-count  = 1
private-subnet-count = 1
```

Use local variables to configure the subnet CIDR blocks

```hcl
locals {
  public-cidrs  = var.public-subnet-count > 0 ? [for i in range(0, var.public-subnet-count * 2 - 1, 2) : cidrsubnet(var.vpc-cidr, 8, i)] : []
  private-cidrs = var.private-subnet-count > 0 ? [for i in range(1, var.private-subnet-count * 2, 2) : cidrsubnet(var.vpc-cidr, 8, i)] : []
}

locals {
  subnet-configuration = {
    public  = local.public-cidrs
    private = local.private-cidrs
  }
}
```

##### DNS hostname and DNS support

DNS hostname and DNS support are enabled by default. To override the default values, use false in the .tfvars file

##### Default tags

Use local variables to configure the default tags.
_The default resource tags are implemented using the CI/CD Pipeline. The following mao just refers to it._
```hcl
locals {
  tags = {
    Environment      = var.environment-name
    ProjectName      = var.project-name
    GitHubRepository = var.github-repo
    GitHubRef        = var.github-ref
    GitHubURL        = var.github-url
    GitHubSHA        = var.github-sha
  }
}
```
#### Note

- To create only public subnets only pass `private-subnet-count=0`
- To create only private subnets only pass `public-subnet-count=0`
- Internet gateway will be created only if atleast one public subnet is created.

## Inputs

| Name| Description| Type|Default|Required |
|--- |--- |--- |--- |--- |
| project-name          | The name of the project                                                     | string | n/a     | yes      |
| vpc-cidr              | The CIDR block for the VPC                                                  | string | 10.0.0.0/16 | yes      |
| enable-dns-hostnames  | Boolean to enable/disable DNS hostnames in the VPC                          | bool   | true    | no       |
| enable-dns-support    | Boolean to enable/disable DNS support in the VPC                            | bool   | true    | no       |
| subnet-configuration  | A map defining the CIDR blocks for public and private subnets               | map    | n/a     | yes      |
| ci-build              | A string representing the CI build identifier                               | string | ""    | yes      |


##### Subnet Configuration Input (Map)

|Name|Description|Type|Default|Required|
|--- |--- |--- |--- |--- |
public|The CIDR blocks for the public subnets|list|n/a|yes|
private|The CIDR blocks for the private subnets|list|n/a|yes|


## Outputs


| Name| Description|
|--- |--- |
|az-list | The list of availability zones in the region|
|vpc-id| VPC Id|
|subnet-configuration| Configuration for public and private subnets|
|internet-gateway-id| The ID of the Internet Gateway|
|public-subnet-ids| The IDs of the public subnets|
|private-subnet-ids| The IDs of the private subnets|
|public-route-table-ids | The IDs of the public route tables|
|private-route-table-ids| The IDs of the private route tables|
|network-acl-id| The ID of the Network ACL|
|public-nacl-ids| The IDs of the public network ACL associations|
|private-nacl-ids| The IDs of the private network ACL associations|