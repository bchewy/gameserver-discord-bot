provider "aws" {
  region = "ap-southeast-1"
}


# resource "aws_cloudwatch_log_group" "squad_server_logs" {
#   name = "squad-logs"
# }

# resource "aws_cloudwatch_log_stream" "squad_server_logs" {
#   name           = aws_instance.ec2.id
#   log_group_name = aws_cloudwatch_log_group.squad_server_logs.name
# }


# Create a new VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "base_vpc"
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "base_subnet"
  }
}

# Create a security group that allows all access
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


# Create an EC2 instance
resource "aws_instance" "ec2" {
  ami                         = "ami-0df7a207adb9748c7"
  # instance_type               = "c5.large"
  instance_type               = "c5n.large"
  # instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.security_grp.id]
  associate_public_ip_address = true
  key_name                    = "BrianJune2023"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  # User Data
  user_data = <<-EOF
              #!/bin/bash             
              sudo dpkg --add-architecture i386
              sudo apt update
              sudo apt install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 -y
              
              echo sleeping
              sleep 5

              adduser squadserver --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
              echo "squadserver:zY3MTg0MzQ3N" | sudo chpasswd
              su - squadserver -c "wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh squadserver"
              
              echo sleeping
              sleep 5

              su - squadserver -c "./squadserver ai"
              
              echo sleeping
              sleep 5

              echo replace-the-config
              cd /home/squadserver/serverfiles/SquadGame/ServerConfig/
              mv Server.cfg Server.cfg.bak
              mv Admins.cfg Admins.cfg.bak
              wget -O Server.cfg https://bchewy.s3.ap-southeast-1.amazonaws.com/ServerConfig/Server.cfg
              wget -O Admins.cfg https://bchewy.s3.ap-southeast-1.amazonaws.com/ServerConfig/Admins.cfg

              chown -R squadserver:squadserver /home/squadserver/serverfiles/SquadGame/ServerConfig/

              echo starting-the-server
              su - squadserver -c "./squadserver start"

              echo "User data script complete" > /tmp/user_data_complete
              echo "READY" > /var/lib/ready

              EOF
    user_data_replace_on_change = true
    # instance_ready_timeout = "5m"

  tags = {
    Name = "Squad Server"
  }
}



# Check if instance is ready
# resource "null_resource" "check_ready" {

#   provisioner "local-exec" {
#   command = <<EOT
#     cmd /C "
#       aws ssm send-command ^
#         --document-name AWS-RunShellScript ^
#         --instance-ids ${aws_instance.ec2.id} ^ 
#         --comment 'Signal ready' ^
#         --parameters '{\"commands\":[\"if [ -f /var/lib/ready ]; then echo READY > \\${aws_ssm_parameter.ready.name}; fi\"]}'^
#         --region ap-southeast-1
#     "
#   EOT
#   }

#   triggers = {
#     ec2_id = aws_instance.ec2.id
#   }

# }



# # Windows local exec
# resource "null_resource" "wait_for_user_data" {
#   provisioner "local-exec" {
#     command = <<EOT

#     EOT
#   }

#   triggers = {
#     instance_id = aws_instance.ec2.id
#   }
# }


# MAC/Linux local exec
# resource "null_resource" "wait_for_user_data" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       until ssh -o StrictHostKeyChecking=no -i BrianJune2023.pem ubuntu@${aws_instance.ec2.public_ip} 'test -f /tmp/user_data_complete'; do
#         sleep 10
#       done
#     EOT
#   }

#   triggers = {
#     instance_id = aws_instance.ec2.id
#   }
# }

output "instance_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "instance_private_ip" {
  value = aws_instance.ec2.private_ip
}
