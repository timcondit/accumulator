terraform {
  backend "remote" {
    organization = "skillfox"
    workspaces {
      name = "skillfox-accumulator"
    }
  }
}

