variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "EC2 size"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Your public IP in CIDR form, like 1.2.3.4/32"
  type        = string
}

variable "key_name" {
  description = "Name of the existing AWS key pair for SSH"
  type        = string
  default     = "jenkins"
}

variable "db_password" {
  description = "Postgres password for the dashboard"
  type        = string
  sensitive   = true
}
