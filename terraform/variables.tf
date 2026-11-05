variable "my_instance_type" {
  description = "The type of the EC2 instance"
  type        = string
}

variable "my_instance_ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP address with /32"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "Enter a valid CIDR address, such as 203.0.113.10/32."
  }
}