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

variable "databricks_vpc_cidr" {
  type        = string
  description = "VPC CIDR created by Databricks"
}

variable "techops_vpc_cidr" {
  type        = string
  description = "VPC CIDR in skillfox-techops to peer with."
}

variable "peering_id" {
  type        = string
  description = "VPC peering id from techops"
}
