terraform {
  backend "s3" {
    bucket         = "mikes-terraform-state"
    key            = "mikes-lambda-authorizer.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}