provider "aws" {
  region = "ap-southeast-1"
}


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "base_vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "base_subnet"
  }
}

resource "aws_security_group" "security_grp" {
  vpc_id = aws_vpc.vpc.id
  name   = "all_access_sg"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This allows access from anywhere. Restrict to your IP in production.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "all_access"
  }
}


resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "base_route_table"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "base_igw"
  }
}


resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.routetable.id
}


resource "aws_ssm_parameter" "ready" {
  name  = "/instance/ready"
  type  = "String"
  value = "NOT_READY"
}


resource "aws_instance" "ec2" {
  ami                         = "ami-0df7a207adb9748c7"
  instance_type               = "c5.large"
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.security_grp.id]
  associate_public_ip_address = true
  key_name                    = "BrianJune2023"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }
  user_data = <<-EOF
              #!/bin/bash             
              sudo dpkg --add-architecture i386
              sudo apt update
              sudo apt install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 -y
              
              adduser csgoserver --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
              echo "csgoserver:zY3MTg0MzQ3N" | sudo chpasswd
              su - csgoserver -c "wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh csgoserver"

              echo sleeping
              sleep 5

              su - csgoserver -c "./csgoserver ai"

              echo replace-the-config

              echo starting-the-server
              su - csgoserver -c "./csgoserver start"

              EOF
  tags = {
    Name = "CSGO Server"
  }
}

locals {
  file_to_check = "/tmp/user_data_complete"
}



# output "instance_public_ip" {
#   value = aws_instance.ec2.public_ip
# }

# output "instance_private_ip" {
#   value = aws_instance.ec2.private_ip
# }
