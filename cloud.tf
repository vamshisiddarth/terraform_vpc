#Set the Provider Information
provider "aws" {
  access_key = "$replace_with_access_key"
  secret_key = "$replace_with_secret_key"
  region     = "${var.region}"
}

#Create the VPC
resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags {
    Name = "main"
  }
}

#Create the Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_cidr_public}"

  tags {
    Name = "Public Subnet"
  }
}

#Create the Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_cidr_private}"

  tags {
    Name = "Private Subnet"
  }
}

#Define the InternetGateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
        Name = "InternetGateway"
    }
}

# Define the Public route table
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Route Table"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

# Define the Private route table
resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Private Route Table"
  }
}

# Assign the route table to the private Subnet
resource "aws_route_table_association" "private-rt" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "terraform security group"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.main.id}"

  tags {
    Name = "Terraform SG Web"
  }
}

# Define the security group for private subnet
resource "aws_security_group" "sgdb"{
  name = "sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.subnet_cidr_public}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.subnet_cidr_public}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.subnet_cidr_public}"]
  }

  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "DB SG"
  }
}

# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "<YOUR_KEY_NAME>"
  public_key = "${file("${var.key_path}")}"
}

# Define webserver inside the public subnet
resource "aws_instance" "wb" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false

   connection {
   user        = "ec2-user"
   agent       = false
   private_key = "${file("sidkey.pem")}"
   }

   provisioner "file" {
    source      = "userdata.sh"
    destination = "/tmp/userdata.sh"
    }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "/tmp/userdata.sh",
    ]
  }
#   user_data = "${file("userdata.sh")}"

  tags {
    Name = "webserver"
  }
}

# Define database inside the private subnet
resource "aws_instance" "db" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private.id}"
   vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
   source_dest_check = false

  tags {
    Name = "database"
  }
}
