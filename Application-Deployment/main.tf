# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "Node" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Node"
  }
}

# Create a public subnet
resource "aws_subnet" "Node_subnet" {
  vpc_id                = aws_vpc.Node.id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Node-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "Node_gateway" {
  vpc_id = aws_vpc.Node.id
  tags = {
    Name = "Node-gateway"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "Node_route_table" {
  vpc_id = aws_vpc.Node.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Node_gateway.id
  }

  tags = {
    Name = "Node-route-table"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "Node_route_table_association" {
  subnet_id      = aws_subnet.Node_subnet.id
  route_table_id = aws_route_table.Node_route_table.id
}

# Create a security group
resource "aws_security_group" "Node_security_group" {
  vpc_id = aws_vpc.Node.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Node-security-group"
  }
}

resource "aws_instance" "Node_instance" {
  ami           = "ami-0e86e20dae9224db8" # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Node_subnet.id
  vpc_security_group_ids = [aws_security_group.Node_security_group.id]
  key_name = "jenkins"  # Ensure that this key exists in AWS EC2

  tags = {
    Name = "Node-instance"
  }

  # Copy index.js


 provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/app",
      "sudo chown ubuntu:ubuntu /home/ubuntu/app"
    ]
 connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
		
  }

  provisioner "file" {
    source      = "index.js"
    destination = "/home/ubuntu/app/index.js"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
  }

  # Copy package.json
  provisioner "file" {
    source      = "package.json"
    destination = "/home/ubuntu/app/package.json"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
  }

  # Ensure directory exists, install packages, and start the app
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nodejs npm",
      "cd /home/ubuntu/app",
      "npm install",  # Install dependencies using package.json
      "nohup node index.js > app.log 2>&1 &"  # Run the application in the background
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
  }
}
