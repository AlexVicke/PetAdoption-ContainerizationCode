variable "VPC_cidr" {
  default = "10.0.0.0/16"
}

variable "VPC-name" {
  default = "PACPJP-VPC-RAFV"
}


variable "Pub_Subnet1_cidr" {
  default = "10.0.1.0/24"
}

variable "Pub_Subnet2_cidr" {
  default = "10.0.2.0/24"
}

variable "Prv_Subnet1_cidr" {
  default = "10.0.3.0/24"
}

variable "Prv_Subnet2_cidr" {
  default = "10.0.4.0/24"
}

variable "Pub_Subnet1-name" {
  default = "PACPJP-PubSbnt1-RAFV"
}

variable "Pub_Subnet2-name" {
  default = "PACPJP-PubSbnt2-RAFV"
}

variable "Prv_Subnet1-name" {
  default = "PACPJP-PrvSbnt1-RAFV"
}

variable "Prv_Subnet2-name" {
  default = "PACPJP-PrvSbnt2-RAFV"
}

variable "Pub_RT_cidr" {
  default = "0.0.0.0/0"
}

variable "Prv_RT_cidr" {
  default = "0.0.0.0/0"
}

variable "PubRT-name" {
  default = "PACPJP-PubRT-RAFV"
}

variable "PrvRT-name" {
  default = "PACPJP-PrvRT-RAFV"
}

variable "IGw-name" {
  default = "PACPJP-IGw-RAFV"
}

variable "NATGw-name" {
  default = "PACPJP-NATGw-RAFV"
}

variable "All-CIDRs" {
  default = "0.0.0.0/0"
}

variable "FE_SGp-name" {
  default = "PACPJP-FE_SGp-RAFV"
}

variable "BE_SGp-name" {
  default = "PACPJP-BE_SGp-RAFV"
}


variable "HTTP-port" {
  default = "80"
}

variable "Jenkins-port" {
  default = "8080"
}

variable "SSH-port" {
  default = "22"
}

variable "Docker-port" {
  default = "8085"
}

variable "Egress-port" {
  default = "0"
}

variable "RDS-port" {
  default = "3306"
}

variable "RDS_cidr" {
  default = "10.0.1.0/24"
}

variable "ami_id" {
  default     = "ami-0f0f1c02e5e4d9d9f"
  description = "this is our ami from eu-west-1"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "path-to-publickey" {
  default     = "~/Keypairs/PetAdoptionEU1.pub"
  description = "this is path to the keypair in our local machine"
}