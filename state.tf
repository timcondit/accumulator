terraform {
  backend "s3" {
    bucket         = "skillfox-terraform-skillfox-databricks2"
    key            = "skillfox-databricks.tfstate"
    region         = "us-east-1"
    role_arn       = "arn:aws:iam::977798128555:role/assume_terraformer_role"
    dynamodb_table = "tf-state-lock"
  }
}
