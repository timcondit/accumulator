
variable "vpc_name" {
  type        = string
  description = "AWS VPC ID"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "aws_region" {
  type        = string
  description = "AWS region id"
}

variable "aws_zones" {
  type        = list(any)
  description = "AWS AZs"
}

variable "aws_acc_num" {
  type        = string
  description = "AWS account number"
}

variable "databricks_aws_acc_num" {
  type        = string
  description = "Databricks' AWS Account number"
}
