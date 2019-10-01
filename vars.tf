variable "ec2_name" {
  type = "map"
  default = {
    "1"   = "Instance A for Tim"
    "2"   = "Instance B for Tim"
  }
}

variable "region" {
  default = "us-east-2"
}

variable "ami_id" {
  default = "ami-00c03f7f7f2ec15c3"
}

variable "aws_vpc_id" {
  default = "vpc-f1295c98"
}
