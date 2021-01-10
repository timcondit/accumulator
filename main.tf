terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "/Users/timcondit/.aws/credentials"
  profile                 = "skillfox"

  # TODO Add the role and policy in code. Create manually for now.
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_acc_num}:role/assume_terraformer_role"
  }
}

###################
# VPC
###################

# TODO Add the VPC in code. Create manually for now.
# VPC created and managed by Databricks.
# $ terraform import aws_vpc.databricks vpc-50c9db2947ee19799
resource "aws_vpc" "databricks" {
  cidr_block = var.databricks_vpc_cidr

  tags = {
    Name = "databricks-f68ba48ac3d44918-4e4e2f24-7c94-04be-29b2-c2715ed9059b"
  }
}

# Peer to skillfox-techops
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = var.peering_id
  auto_accept               = true

  tags = {
    Name = "techops"
    Side = "Accepter"
  }
}

## Route table associated with Databricks created VPC: vpc-50c9db2947ee19799
## Route Table ID: rtb-cc205eb838c58c68e

# TODO Add the route table in code. Create manually for now.
# $ terraform import aws_route_table.databricks_vpc_routes rtb-cc205eb838c58c68e
resource "aws_route_table" "databricks_vpc_routes" {
  vpc_id = aws_vpc.databricks.id

  # Not using inline rules as that makes terraform want to redo all the rules.
}

# TODO Add the route table in code. Create manually for now.
# $ terraform import aws_route.databricks_vpc_route_gateway rtb-cc205eb838c58c68e_10.220.0.0/16
resource "aws_route" "databricks_vpc_route_gateway" {
  route_table_id         = aws_route_table.databricks_vpc_routes.id
  destination_cidr_block = var.databricks_vpc_cidr
  gateway_id             = "local"
}

# TODO Add the route table in code. Create manually for now.
# $ terraform import aws_route.databricks_vpc_route_techops_peer rtb-cc205eb838c58c68e_10.196.0.0/18
resource "aws_route" "databricks_vpc_route_techops_peer" {
  route_table_id            = aws_route_table.databricks_vpc_routes.id
  destination_cidr_block    = var.techops_vpc_cidr
  vpc_peering_connection_id = var.peering_id
}

# TODO Add the route table in code. Create manually for now.
# $ terraform import aws_route.databricks_vpc_route_internet_gateway rtb-cc205eb838c58c68e_0.0.0.0/0
resource "aws_route" "databricks_vpc_route_internet_gateway" {
  route_table_id         = aws_route_table.databricks_vpc_routes.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "igw-a848bbcfd14d1fe66"
}

# Enables jupyter notebook integration.
# I'm unsure if this security group is dynamically changed by Databricks.
# Due to the control note above, I'm only adding the rule.
# See https://docs.databricks.com/clusters/configure.html#ssh-access
# This integration only works via public IP and port and I haven't gotten it
# to work over a tunnel.
#
# Does this need to be terraform import'ed? It's zeroed out anyway. Should I just skip it?
# resource "aws_security_group_rule" "jupyter_notebook" {
#   count             = 0 # deleting this resource
#   type              = "ingress"
#   from_port         = 2200
#   to_port           = 2200
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = "sg-72e751db65eed6c5e"
#   description       = "SSH Port for Jupyter Notebook integration."
# }

###################
# S3 Bucket
###################

resource "aws_s3_bucket" "databricks_root" {
  bucket = "skillfox-databricks-rootbucket"
  region = var.aws_region

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "cgp_data_lake" {
  bucket = "cgp-data-lake"
}

resource "aws_s3_bucket_object" "sandbox" {
  bucket = aws_s3_bucket.cgp_data_lake.id
  acl    = "private"
  key    = "sandbox/"
  source = "/dev/null"
}

# Policy comes from https://docs.databricks.com/administration-guide/account-settings/aws-storage.html#aws-storage
resource "aws_s3_bucket_policy" "databricks_root_policy" {
  bucket = aws_s3_bucket.databricks_root.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Grant Databricks Access",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.databricks_aws_acc_num}:root"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::skillfox-databricks-rootbucket/*",
        "arn:aws:s3:::skillfox-databricks-rootbucket"
      ]
    }
  ]
}
POLICY
}

#####################
# EC2 & EC2 security
#####################

resource "aws_security_group" "allow_ssh_via_vpn" {
  name        = "AllowSSHviaVPN"
  description = "Allow inbound ssh traffic via VPCs."
  vpc_id      = aws_vpc.databricks.id

  ingress {
    description = "SSH within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.databricks.cidr_block]
  }

  ingress {
    description = "SSH with techops VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.techops_vpc_cidr]
  }

  tags = {
    Name = "AllowSSHviaVPN"
  }
}
