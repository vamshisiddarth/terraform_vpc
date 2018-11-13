variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_public" {
  default = "10.0.1.0/24"
}

variable "subnet_cidr_private" {
  default = "10.0.2.0/24"
}

data "aws_availability_zones" "available" {}

variable "ami" {
  default = "<YOUR_AMI_ID>"
}

variable "key_path" {
  default = "<YOUR_KEY>"
}
