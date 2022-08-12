#CREATE VPC
resource "aws_vpc" "PACPJP-VPC-RAFV" {
  cidr_block       = var.VPC_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.VPC-name
  }
}


#CREATE PUBLIC SUBNET1

resource "aws_subnet" "PACPJP-PubSbnt1-RAFV" {
  vpc_id            = aws_vpc.PACPJP-VPC-RAFV.id
  cidr_block        = var.Pub_Subnet1_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = var.Pub_Subnet1-name
  }
}


#CREATE PUBLIC SUBNET2

resource "aws_subnet" "PACPJP-PubSbnt2-RAFV" {
  vpc_id            = aws_vpc.PACPJP-VPC-RAFV.id
  cidr_block        = var.Pub_Subnet2_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = var.Pub_Subnet2-name
  }
}


#CREATE PRIVATE SUBNET1

resource "aws_subnet" "PACPJP-PrvSbnt1-RAFV" {
  vpc_id            = aws_vpc.PACPJP-VPC-RAFV.id
  cidr_block        = var.Prv_Subnet1_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = var.Prv_Subnet1-name
  }
}


#CREATE PRIVATE SUBNET2

resource "aws_subnet" "PACPJP-PrvSbnt2-RAFV" {
  vpc_id            = aws_vpc.PACPJP-VPC-RAFV.id
  cidr_block        = var.Prv_Subnet2_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = var.Prv_Subnet2-name
  }
}


#CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "PACPJP-IGw-RAFV" {
  vpc_id = aws_vpc.PACPJP-VPC-RAFV.id

  tags = {
    Name = var.IGw-name
  }
}


#CREATE ELASTIC IP FOR NATGw
resource "aws_eip" "PACPJP-EIP-RAFV" {
  vpc = true
}


#CREATE NAT GATEWAY FOR PRIVATE SUBNET
resource "aws_nat_gateway" "PACPJP-NATGw-RAFV" {
  allocation_id = aws_eip.PACPJP-EIP-RAFV.id
  subnet_id     = aws_subnet.PACPJP-PubSbnt1-RAFV.id

  tags = {
    Name = var.NATGw-name
  }
}


#CREATE PUBLIC ROUTE TABLE
resource "aws_route_table" "PACPJP-PubRT-RAFV" {
  vpc_id = aws_vpc.PACPJP-VPC-RAFV.id

  route {
    cidr_block = var.Pub_RT_cidr
    gateway_id = aws_internet_gateway.PACPJP-IGw-RAFV.id
  }

  tags = {
    Name = var.PubRT-name
  }
}


#CREATE PRIVATE ROUTE TABLE
resource "aws_route_table" "PACPJP-PrvRT-RAFV" {
  vpc_id = aws_vpc.PACPJP-VPC-RAFV.id

  route {
    cidr_block = var.Prv_RT_cidr
    gateway_id = aws_nat_gateway.PACPJP-NATGw-RAFV.id
  }

  tags = {
    Name = var.PrvRT-name
  }
}


#CREATE PUBLIC Sbnt1 w/Pub ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Pub1-RTAssc-RAFV" {
  subnet_id      = aws_subnet.PACPJP-PubSbnt1-RAFV.id
  route_table_id = aws_route_table.PACPJP-PubRT-RAFV.id
}


#CREATE PUBLIC Sbnt2 w/Pub ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Pub2-RTAssc-RAFV" {
  subnet_id      = aws_subnet.PACPJP-PubSbnt2-RAFV.id
  route_table_id = aws_route_table.PACPJP-PubRT-RAFV.id
}


#CREATE PRIVATE Sbnt1 w/Prv ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Prv1-RTAssc-RAFV" {
  subnet_id      = aws_subnet.PACPJP-PrvSbnt1-RAFV.id
  route_table_id = aws_route_table.PACPJP-PrvRT-RAFV.id
}


#CREATE PRIVATE Sbnt2 w/Prv ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "PACPJP-Prv2-RTAssc-RAFV" {
  subnet_id      = aws_subnet.PACPJP-PrvSbnt2-RAFV.id
  route_table_id = aws_route_table.PACPJP-PrvRT-RAFV.id
}


#CREATE FRONTEND SECURITY GROUP
resource "aws_security_group" "PACPJP-FE_SGp-RAFV" {
  name        = "PACPJP-FE_SGp-RAFV"
  description = "Allow SSH & Jenkins inbound traffic"
  vpc_id      = aws_vpc.PACPJP-VPC-RAFV.id

  ingress {
    description = "HTTP from VPC"
    from_port   = var.HTTP-port
    to_port     = var.HTTP-port
    protocol    = "tcp"
    cidr_blocks = [var.All-CIDRs]
  }

  ingress {
    description = "Jenkins from VPC"
    from_port   = var.Jenkins-port
    to_port     = var.Jenkins-port
    protocol    = "tcp"
    cidr_blocks = [var.All-CIDRs]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = var.SSH-port
    to_port     = var.SSH-port
    protocol    = "tcp"
    cidr_blocks = [var.All-CIDRs]
  }

  ingress {
    description = "Docker from VPC"
    from_port   = var.Docker-port
    to_port     = var.Docker-port
    protocol    = "tcp"
    cidr_blocks = [var.All-CIDRs]
  }

  egress {
    from_port   = var.Egress-port
    to_port     = var.Egress-port
    protocol    = "-1"
    cidr_blocks = [var.All-CIDRs]
  }

  tags = {
    Name = var.FE_SGp-name
  }
}


#CREATE BACKEND SECURITY GROUP
resource "aws_security_group" "PACPJP-BE_SGp-RAFV" {
  name        = "PACPJP-BE_SGp-RAFV"
  description = "Allow SSH & MySQL inbound traffic"
  vpc_id      = aws_vpc.PACPJP-VPC-RAFV.id

  ingress {
    description = "RDS from NAT"
    from_port   = var.RDS-port
    to_port     = var.RDS-port
    protocol    = "tcp"
    cidr_blocks = [var.RDS_cidr]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = var.SSH-port
    to_port     = var.SSH-port
    protocol    = "tcp"
    cidr_blocks = [var.All-CIDRs]
  }

  egress {
    from_port   = var.Egress-port
    to_port     = var.Egress-port
    protocol    = "-1"
    cidr_blocks = [var.All-CIDRs]
  }

  tags = {
    Name = var.BE_SGp-name
  }
}

#UTILISE A KEYPAIR FOR EC2 ACCESS
resource "aws_key_pair" "PetAdoption1_key" {
  key_name   = "PetAdoption1_key"
  public_key = file(var.path-to-publickey)
}
#create new keypair and share amongst the team

#CREATE JENKINS EC2 INSTANCE
resource "aws_instance" "PACPJP-JenkinsServer-RAFV" {
  ami           = var.ami_id
  instance_type = var.instance_type
  # iam_instance_profile      = aws_iam_instance_profile.PACPJP_profile.name
  subnet_id                   = aws_subnet.PACPJP-PubSbnt1-RAFV.id
  key_name                    = aws_key_pair.PetAdoption1_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.PACPJP-FE_SGp-RAFV.id]

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install wget -y
sudo yum install git -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo yum install fontconfig -y
sudo yum install java-11-openjdk -y
sudo yum install maven -y 
#sudo yum install java-1.8.0-openjdk-devel -y --nobest
#cat /etc/redhat-release
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
sudo systemctl daemon-reload
sudo systemctl start jenkins
#sudo systemctl enable jenkins
#sudo systemctl status jenkins
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
echo "license_key: 18b989848e83ee998df70e98b20b815c02b0NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
#=========MODULE TO INSTALL SSHPASS FOR USER/PASSWORD SUBMIT AUTOMATION==========
sudo yum install sshpass -y
sudo su
echo Admin123@ | passwd ec2-user --stdin
echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd reload
sudo chmod -R 700 .ssh/
sudo chown -R ec2-user:ec2user .ssh/
sudo su - ec2-user -c "ssh-keygen -f ~/.ssh/jenkinskey_rsa -t rsa -b 4096 -m PEM -N ''"
sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
sudo su - ec2-user -c 'sshpass -p "Admin123@" ssh-copy-id -i /home/ec2-user/.ssh/jenkinskey_rsa.pub ec2-user@${data.aws_instance.PACPJP-Ansiblehost-RAFV.public_ip} -p 22'
ssh-copy-id -i /home/ec2-user/.ssh/jenkinskey_rsa.pub ec2-user@localhost -p 22
-p 22 can be changed to any port we want to assign
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
sudo service sshd restart
sudo hostnamectl set-hostname Jenkins
EOF

  tags = {
    Name = "PACPJP-JenkinsServer-RAFV"
  }
}


# PROVISION DOCKER HOST
resource "aws_instance" "PACPJP-dockerhost-RAFV" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.PACPJP-PubSbnt1-RAFV.id
  vpc_security_group_ids      = [aws_security_group.PACPJP-FE_SGp-RAFV.id]
  key_name                    = aws_key_pair.PetAdoption1_key.key_name
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo yum install docker-ce-cli -y
sudo yum install containerd.io -y
sudo yum install python3 -y
sudo yum install python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo pip3 install docker-py 
sudo systemctl start docker
sudo systemctl enable docker
echo "license_key: 18b989848e83ee998df70e98b20b815c02b0NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo usermod -aG docker ec2-user
sudo hostnamectl set-hostname Docker
EOF
  tags = {
    Name = "PACPJP-dockerhost-RAFV"
  }
}
#=========MODULE TO INSTALL SSHPASS FOR USER/PASSWORD SUBMIT AUTOMATION==========
# sudo yum install sshpass -y
# sudo su
# echo Admin123@ | passwd ec2-user --stdin
# echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
# sudo service sshd reload
# sudo chmod -R 700 .ssh/
#Why chown is not needed here as in Jenkins? (sudo chown -R ec2-user:ec2user .ssh/) ===========
# sudo chmod 600 .ssh/authorized_keys
#Why usermod is not needed in docker? (sudo usermod -aG docker ec2-user)



#WHAT ARE THE REASONS TO CREATE THIS DATA RESOURCES? ====================

data "aws_instance" "PACPJP-dockerhost-RAFV" {
  filter {
    name   = "tag:Name"
    values = ["PACPJP-dockerhost-RAFV"]
  }

  depends_on = [
    aws_instance.PACPJP-dockerhost-RAFV
  ]
}


# PROVISION ANSIBLE HOST
resource "aws_instance" "PACPJP-Ansiblehost-RAFV" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.PetAdoption1_key.key_name
  #iam_instance_profile  = aws_iam_instance_profile.ansible_host_instance_profile.id
  subnet_id                   = aws_subnet.PACPJP-PubSbnt1-RAFV.id
  vpc_security_group_ids      = [aws_security_group.PACPJP-FE_SGp-RAFV.id]
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install python3.8 -y
sudo alternatives --set python /usr/bin/python3.8
sudo yum install python3-pip -y
#What is the line for? ========= (sudo pip3 install docker-py) ===========
sudo yum install ansible -y
sudo pip3 install ansible --user
sudo chown ec2-user:ec2-user /etc/ansible
#What is the line for? ========= (sudo chown ec2-user:ec2-user /etc/ansible) ===========
sudo yum install -y yum-utils -y
sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/sshpass-1.06-2.el7.x86_64.rpm 
#=========MODULE TO INSTALL NEW RELIC==========
echo "license_key: 18b989848e83ee998df70e98b20b815c02b0NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/amazonlinux/2/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
#=========MODULE TO INSTALL SSHPASS FOR USER/PASSWORD SUBMIT AUTOMATION==========
sudo yum install sshpass -y
sudo su
echo Admin123@ | passwd ec2-user --stdin
echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd reload
sudo chmod -R 700 .ssh/
sudo chown -R ec2-user:ec2user .ssh/
sudo su - ec2-user -c "ssh-keygen -f ~/.ssh/pap2anskey_rsa -t rsa -N ''"
sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
sudo su - ec2-user -c 'sshpass -p "Admin123@" ssh-copy-id -i /home/ec2-user/.ssh/pap2anskey_rsa.pub ec2-user@${data.aws_instance.PACPJP-dockerhost-RAFV.public_ip} -p 22'
#=========Why in the line above the new ansible key is being located in docker but in docker host provisioned the docker key was located in ansible instead? ==========================
ssh-copy-id -i /home/ec2-user/.ssh/pap2anskey_rsa.pub ec2-user@localhost -p 22
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
# ========== WHAT IS THE MODULE BELOW FOR?=========
cd /etc/
sudo chown ec2-user:ec2user hosts
cat <<EOT>> /etc/ansible/hosts
localhost ansible_connection=local
[docker_host]
${data.aws_instance.PACPJP-dockerhost-RAFV.public_ip}  ansible_ssh_private_key_file=/home/ec2-user/.ssh/pap2anskey_rsa
EOT
sudo mkdir /opt/docker
sudo chown -R ec2-user:ec2-user /opt/docker
sudo chmod -R 700 /opt/docker
touch /opt/docker/Dockerfile
cat <<EOT>> /opt/docker/Dockerfile
# ===========Pull tomcat image from docker hub==============
FROM tomcat
FROM openjdk:8-jre-slim
# ===========Copy war file on the container================
COPY spring-petclinic-2.4.2.war app/
WORKDIR app/
RUN pwd
RUN ls -al
ENTRYPOINT [ "java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"]
EOT
# ===========MODULE TO DETERMINE ANSIBLE PLAYBOOKS================
touch /opt/docker/docker-image.yml
cat <<EOT>> /opt/docker/docker-image.yml
---
 - hosts: localhost
  #root access to user
   become: true

   tasks:
   - name: login to dockerhub
     command: docker login -u cloudhight -p CloudHight_Admin123@

   - name: Create docker image from Pet Adoption war file
     command: docker build -t pet-adoption-image .
     args:
       chdir: /opt/docker

   - name: Add tag to image
     command: docker tag pet-adoption-image cloudhight/pet-adoption-image

   - name: Push image to docker hub
     command: docker push cloudhight/pet-adoption-image

   - name: Remove docker image from Ansible node
     command: docker rmi pet-adoption-image cloudhight/pet-adoption-image
     ignore_errors: yes
EOT
touch /opt/docker/docker-container.yml
cat <<EOT>> /opt/docker/docker-container.yml
---
 - hosts: docker_host
   become: true

   tasks:
   - name: login to dockerhub
     command: docker login -u cloudhight -p CloudHight_Admin123@

   - name: Stop any container running
     command: docker stop pet-adoption-container
     ignore_errors: yes

   - name: Remove stopped container
     command: docker rm pet-adoption-container
     ignore_errors: yes

   - name: Remove docker image
     command: docker rmi cloudhight/pet-adoption-image
     ignore_errors: yes

   - name: Pull docker image from dockerhub
     command: docker pull cloudhight/pet-adoption-image
     ignore_errors: yes

   - name: Create container from pet adoption image
     command: docker run -it -d --name pet-adoption-container -p 8080:8085 cloudhight/pet-adoption-image
     ignore_errors: yes
EOT
cat << EOT > /opt/docker/newrelic.yml
---
 - hosts: docker
   become: true

   tasks:
   - name: install newrelic agent
     command: docker run \
                     -d \
                     --name newrelic-infra \
                     --network=host \
                     --cap-add=SYS_PTRACE \
                     --privileged \
                     --pid=host \
                     -v "/:/host:ro" \
                     -v "/var/run/docker.sock:/var/run/docker.sock" \
                     -e NRIA_LICENSE_KEY=18b989848e83ee998df70e98b20b815c02b0NRAL \
                     newrelic/infrastructure:latest
EOT
sudo hostnamectl set-hostname Ansible
EOF
  tags = {
    Name = "PACPJP-Ansiblehost-RAFV"
  }

  # MODULE TO INSTALL AWS_CLI IN USER DATA
  # sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  # sudo unzip awscliv2.zip
  # sudo ./aws/install
  # ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
  # sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
  # sudo ln -svf /usr/local/bin/aws /usr/bin/aws
}

data "aws_instance" "PACPJP-Ansiblehost-RAFV" {
  filter {
    name   = "tag:Name"
    values = ["PACPJP-Ansiblehost-RAFV"]
  }

  depends_on = [
    aws_instance.PACPJP-Ansiblehost-RAFV
  ]
}


#PROVISION SUBNET_GROUP FOR RDS
resource "aws_db_subnet_group" "PACPJP-SbntGp-RAFV" {
  name       = "pacpjp-sbntgp-rafv"
  subnet_ids = [aws_subnet.PACPJP-PrvSbnt1-RAFV.id, aws_subnet.PACPJP-PrvSbnt2-RAFV.id]

  tags = {
    Name = "PACPJP-SbntGp-RAFV"
  }
}


#PROVISION RDS
resource "aws_db_instance" "PACPJP-RDS-RAFV" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = "rdsrafv"
  username               = "admin"
  password               = "admin123"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.PACPJP-SbntGp-RAFV.name
  vpc_security_group_ids = [aws_security_group.PACPJP-BE_SGp-RAFV.id]
  identifier             = "rdsrafv"

  tags = {
    Name = "PACPJP-SbntGp-RAFV"
  }
}


#SECOND STAGE - HIGH AVAILABILITY
#The rest of the script should be applied after Application deployment

#Add an Application Load Balancer
resource "aws_lb" "PACPJP-AppLB-RAFV" {
  name                       = "PACPJP-AppLB-RAFV"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.PACPJP-FE_SGp-RAFV.id]
  subnets                    = [aws_subnet.PACPJP-PubSbnt1-RAFV.id, aws_subnet.PACPJP-PubSbnt2-RAFV.id]
  enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }
  tags = {
    Environment = "RAFVprod"
  }
}


#Create a Target Group for Load Balancer
resource "aws_lb_target_group" "PACPJP-LBTgtGp-RAFV" {
  name        = "PACPJP-LBTgtGp-RAFV"
  #target_type = "alb" #run as is or delete code line
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.PACPJP-VPC-RAFV.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    #timeout             = 60
    interval            = 30
    path                = "/"
  }
}


#Add a load balancer Listener
resource "aws_lb_listener" "PACPJP-LBLstnr-RAFV" {
  load_balancer_arn = aws_lb.PACPJP-AppLB-RAFV.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PACPJP-LBTgtGp-RAFV.arn
  }
}


#Create Target group attachment
resource "aws_lb_target_group_attachment" "PACPJP-LBTgtGpAtt-RAFV" {
  target_group_arn = aws_lb_target_group.PACPJP-LBTgtGp-RAFV.arn
  target_id        = aws_instance.PACPJP-dockerhost-RAFV.id
  port             = 8080
}


#Create Docker_Host AMI Image
resource "aws_ami_from_instance" "PACPJP-dockerhost-AMI-RAFV" {
  name                    = "PACPJP-dockerhost-AMI-RAFV"
  source_instance_id      = data.aws_instance.PACPJP-dockerhost-RAFV.id
  snapshot_without_reboot = true

  depends_on = [
    aws_instance.PACPJP-dockerhost-RAFV,
  ]
  tags = {
    Name = "PACPJP-dockerhost-AMI-RAFV"
  }
}


#Provision Docker-launch-configuration
resource "aws_launch_configuration" "PACPJP-dockerhost-LchCfg-RAFV" {
  name_prefix                 = "PACPJP-dockerhost-LchCfg-RAFV"
  image_id                    = aws_ami_from_instance.PACPJP-dockerhost-AMI-RAFV.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.PetAdoption1_key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.PACPJP-FE_SGp-RAFV.id]

  user_data = <<-EOF
#!/bin/bash
sudo systemctl start docker
sudo systemctl enable docker
sudo docker start pet-adoption-container
sudo hostnamectl set-hostname DockerASG
EOF

  lifecycle {
    create_before_destroy = true
  }
}


#Creating Autoscaling Group
resource "aws_autoscaling_group" "PACPJP-dockerhost-ASG-RAFV" {
  name                      = "PACPJP-dockerhost-ASG-RAFV"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 3
  force_delete         = true
  launch_configuration = aws_launch_configuration.PACPJP-dockerhost-LchCfg-RAFV.name
  vpc_zone_identifier  = [aws_subnet.PACPJP-PubSbnt1-RAFV.id, aws_subnet.PACPJP-PubSbnt2-RAFV.id]
  target_group_arns    = ["${aws_lb_target_group.PACPJP-LBTgtGp-RAFV.arn}"]

  tag {
    key                 = "Name"
    value               = "PACPJP-DockerASG-RAFV"
    propagate_at_launch = true
  }

  # initial_lifecycle_hook {
  #   name                 = "PACPJP-DockerASG-lifecycle"
  #   default_result       = "CONTINUE"
  #   heartbeat_timeout    = 2000
  #   lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  # }
}


#Creating Autoscaling Policy
resource "aws_autoscaling_policy" "PACPJP-ASG-policy-RAFV" {
  name                   = "PACPJP-ASG-policy-RAFV"
  policy_type            = "TargetTrackingScaling"
  #scaling_adjustment     = 3
  adjustment_type        = "ChangeInCapacity"
  # cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.PACPJP-dockerhost-ASG-RAFV.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}


#Create Route 53
resource "aws_route53_zone" "PACPJP-Route53-RAFV" {
  name = var.domain_name

  tags = {
    Environment = "RAFVprod"
  }
}
resource "aws_route53_record" "PACPJP-Arecord-RAFV" {
  zone_id = aws_route53_zone.PACPJP-Route53-RAFV.zone_id
  name    = var.domain_name
  type    = "A"
  # ttl     = "30"
  alias {
    name                   = aws_lb.PACPJP-AppLB-RAFV.dns_name
    zone_id                = aws_lb.PACPJP-AppLB-RAFV.zone_id
    evaluate_target_health = false
  }
}