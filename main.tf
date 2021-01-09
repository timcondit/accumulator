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

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_acc_num}:role/assume_terraformer_role"
  }
}

###################
# VPC
###################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-gw"
  }
}

resource "aws_subnet" "db_subnets" {
  count             = length(var.aws_zones)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.aws_zones[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 12, count.index)

  tags = {
    Name = "${var.aws_zones[count.index]}.${var.vpc_name}.db"
    type = "db"
  }
}

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
