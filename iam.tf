###################
# IAM
###################

################ Roles ################
resource "aws_iam_role" "cgp_ec2_role" {
  name = "cgp-ec2-role"

  description = "Role that allows ec2 instances to access data in various s3 buckets."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "databricks_role" {
  name        = "databricks-role"
  description = "Role used by databricks for cross-account access."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${var.databricks_aws_acc_num}:root" },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
  EOF
}

resource "aws_iam_role" "data_scientist" {
  name               = "data-scientist"
  assume_role_policy = templatefile("templates/assumeRoleDataScientist.json.tmpl", {})
}

################ Instance Profiles ################
resource "aws_iam_instance_profile" "cgp_ec2_profile" {
  name = "cgp-ec2-profile"
  role = aws_iam_role.cgp_ec2_role.name
}

################ Policies ################
resource "aws_iam_policy" "cgp_ec2_role_access_policy" {
  name        = "cgp-ec2-role-access-policy"
  path        = "/"
  description = "CGP ec2 role access policy"

  policy = file("${path.module}/policies/cgp_ec2_role_access_policy.json")
}

# The file contents from https://docs.databricks.com/administration-guide/account-settings/aws-accounts.html
resource "aws_iam_policy" "databricks_role_access_policy" {
  name        = "databricks-role-access-policy"
  path        = "/"
  description = "Databricks role Access Policy"

  policy = file("${path.module}/policies/databricks_role_access_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_cgp_ec2_role_access_policy" {
  role       = aws_iam_role.cgp_ec2_role.name
  policy_arn = aws_iam_policy.cgp_ec2_role_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_databricks_role_access_policy" {
  role       = aws_iam_role.databricks_role.name
  policy_arn = aws_iam_policy.databricks_role_access_policy.arn
}

resource "aws_iam_policy" "data_scientist_role_policy" {
  name        = "data-scientist-role-policy"
  path        = "/"
  description = "Data Scientist role policy"
  policy      = file("${path.module}/policies/data_scientist_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_data_scientist_role_policy" {
  role       = aws_iam_role.data_scientist.name
  policy_arn = aws_iam_policy.data_scientist_role_policy.arn
}

resource "aws_iam_policy" "data_scientist_ec2_policy" {
  name        = "data-scientist-ec2-policy"
  path        = "/"
  description = "Data Scientist ec2 policy"
  policy      = file("${path.module}/policies/data_scientist_ec2_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_data_scientist_ec2_policy" {
  role       = aws_iam_role.data_scientist.name
  policy_arn = aws_iam_policy.data_scientist_ec2_policy.arn
}
