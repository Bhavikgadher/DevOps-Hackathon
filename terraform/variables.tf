variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "my-key"
}
