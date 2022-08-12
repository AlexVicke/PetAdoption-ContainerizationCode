output "JenkinsServer_ip" {
  value = aws_instance.PACPJP-JenkinsServer-RAFV.public_ip
}

output "DockerHost_ip" {
  value = aws_instance.PACPJP-dockerhost-RAFV.public_ip
}

output "Ansiblehost_IP" {
  value = aws_instance.PACPJP-Ansiblehost-RAFV.public_ip
}

output "lb_dns" {
  value = aws_lb.PACPJP-AppLB-RAFV.dns_name
}

output "Name_Servers" {
  value = aws_route53_zone.PACPJP-Route53-RAFV.name_servers
}

