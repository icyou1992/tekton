terraform {
  backend "s3" {
    bucket         = "tfstate-pfe-056231226580"
    key            = "tfstate/pfe/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "tfstate-pfe-056231226580"
    encrypt        = true
  }
}
