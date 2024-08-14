resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow inbound traffic for Jenkins"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-04a81a99f5ec58529" 
  instance_type = "t2.micro"
  key_name = "test-key"
  security_groups = [aws_security_group.jenkins_sg.name]

  tags = {
    Name = "JenkinsServer"
  }
}

resource "null_resource" "installer"{

  # ssh to instance 
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("./test-key.pem")
    host = aws_instance.jenkins.public_ip
  }

  # copy script from local to remote
  provisioner "file" {
    source = "install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
  }
  # congifure permissions & execute install script
  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod +x /tmp/install_jenkins.sh",
      "sh /tmp/install_jenkins.sh",
     ]
  }

  depends_on = [ aws_instance.jenkins ]

}




