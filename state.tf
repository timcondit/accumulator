terraform {
  backend "remote" {
    organization = "skillfox"
    workspaces {
      name = "skillfox-accumulator"
    }
  }
}

#  backend "s3" {
#    bucket         = "skillfox-terraform-skillfox-databricks2"
#    key            = "skillfox-databricks.tfstate"
#    region         = "us-east-1"
#    role_arn       = "arn:aws:iam::252205905963:role/assume_terraformer_role"
#    dynamodb_table = "tf-state-lock"
#  }
