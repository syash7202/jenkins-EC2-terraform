output "website-url" {
  value = join ("",["http://",aws_instance.jenkins.public_ip,":","8080"])
}