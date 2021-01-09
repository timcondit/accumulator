###################
# IAM
###################

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

# The file contents from https://docs.databricks.com/administration-guide/account-settings/aws-accounts.html
resource "aws_iam_policy" "databricks_role_access_policy" {
  name        = "databricks-role-access-policy"
  path        = "/"
  description = "Databricks role Access Policy"

  policy = file("${path.module}/policies/databricks_role_access_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_databricks_role_access_policy" {
  role       = aws_iam_role.databricks_role.name
  policy_arn = aws_iam_policy.databricks_role_access_policy.arn
}
