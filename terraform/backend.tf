terraform {
  backend "s3" {
    bucket         = "skillpulse-terraform-state-bucket" # MUST CREATE THIS BUCKET FIRST
    key            = "ec2/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "skillpulse-terraform-locks"        # MUST CREATE THIS TABLE FIRST
    encrypt        = true
  }
}
