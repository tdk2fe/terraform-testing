provider "aws" {
  profile   = "default"
  region    = "${var.region}"
}

resource "aws_subnet" "main" {
  vpc_id  = "${var.aws_vpc_id}"
  cidr_block    = "172.31.48.0/28"

  tags = {
    Owner = "Tim Krupinski"
  }
}

resource "aws_network_interface" "eni_A" {
  subnet_id = "${aws_subnet.main.id}"
  security_groups = ["${aws_security_group.tims_sg.id}"]
}

resource "aws_network_interface" "eni_B" {
  subnet_id = "${aws_subnet.main.id}"
  security_groups = ["${aws_security_group.tims_sg.id}"]
}


resource "aws_instance" "Instance_A" {
  ami     = "${var.ami_id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.tims_profile.name}"
  network_interface {
    network_interface_id  = "${aws_network_interface.eni_A.id}"
    device_index          = 0
  }
  tags = {
    Name = "${var.ec2_name["1"]}"
    Owner = "Tim Krupinski"
  }
}

resource "aws_instance" "Instance_B" {
  ami     = "${var.ami_id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.tims_profile.name}"
  network_interface {
    network_interface_id  = "${aws_network_interface.eni_B.id}"
    device_index          = 0
  }
  tags = {
    Name = "${var.ec2_name["2"]}"
    Owner = "Tim Krupinski"
  }
}

resource "aws_security_group" "tims_sg" {
  name  = "Tims SG"
  description   = "Allow intra-ec2 traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    self        = true
    protocol    = -1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
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