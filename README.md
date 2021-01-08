# Skillfox Databricks Terraform setup

Run to create/manage AWS resources

1. VPC
2. Internet Gateway
3. IAM resources
4. S3 Buckets - various

### Environment specific files

1. state.tf - add environment specific bucket names and provisioner role
2. terraform.tfvars - add environment specific setting here
```bash
aws_region = "<region name>"
aws_zones = ["<list of zones go here""]
aws_acc_num = "<account number>"

vpc_cidr = "<vpc cidr block>"
vpc_name = "<vpc tag>"
```

### Run it!

The first thing you need after updating your environment specific files.
`terraform init`

That'll get you started. From here the standard
`terraform apply`
can be run
