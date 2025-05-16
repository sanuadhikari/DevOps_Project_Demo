# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create the EC2 instance
resource "aws_instance" "hello_world_app" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.http_ssh.id]
  key_name      = var.key_pair_name # Ensure you have an EC2 key pair created

  # User data script to install Docker and run the container
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              service docker start
              usermod -a -G docker ec2-user
              # Login to Docker Hub (replace with your username and password/token)
              # echo ${var.docker_password} | docker login --username ${var.docker_username} --password-stdin
              # Pull and run the Docker image (replace with your Docker Hub username and image name)
              docker run -d -p 80:80 ${var.docker_image_name}
              EOF

  tags = {
    Name = "hello-world-app-instance"
  }
}