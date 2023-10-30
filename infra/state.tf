terraform {
  backend "s3" {
    bucket         = "mikes-lambda-authorizer-terraform-state"
    key            = var.states_file
    region         = var.region
    encrypt        = true
  }
}