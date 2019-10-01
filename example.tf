provider "aws" {
  profile   = "default"
  region    = var.region
}

resource "aws_instance" "tims-example" {
  ami     = "ami-00c03f7f7f2ec15c3"
  instance_type = "t2.micro"
  depends_on = [aws_s3_bucket.tims-bucket]
  iam_instance_profile = aws_iam_instance_profile.tims_profile.name
  associate_public_ip_address = false
  tags = {
    Name = var.ec2_name
    Owner = "Tim Krupinski"
  }
}

resource "aws_s3_bucket" "tims-bucket" {
  bucket = "e785vs-tims-bucket"
  acl = "private"
  tags = {
    Owner = "Tim Krupinski"
  }
}

resource "aws_iam_role" "role" {
  name  = "TimsEC2Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Owner = "Tim Krupinski"
  }
}

resource "aws_iam_role_policy_attachment" "TimsEC2-InstanceRole" {
  role          = "${aws_iam_role.role.name}"
  policy_arn    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "tims_profile" {
  name  = "Tims_Profile"
  role  = "${aws_iam_role.role.name}"
}