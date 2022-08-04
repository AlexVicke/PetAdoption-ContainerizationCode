output "JenkinsServer_ip" {
  value = aws_instance.PACPJP-JenkinsServer-RAFV.public_ip
}

output "DockerHost_ip" {
  value = aws_instance.PACPJP-dockerhost-RAFV.public_ip
}

output "Ansiblehost_IP" {
  value = aws_instance.PACPJP-Ansiblehost-RAFV.public_ip
}