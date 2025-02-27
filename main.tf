# main.tf

# Configure the Linode provider
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.0" # Use a compatible version
    }
  }
}

provider "linode" {
  token = var.linode_token # Token will be passed from Jenkins environment variable
}

# Define variables
variable "linode_token" {
  description = "Linode API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Linode region to deploy the instance"
  type        = string
  default     = "us-east" # Default region, adjust as needed
}

variable "instance_type" {
  description = "Linode instance type"
  type        = string
  default     = "g6-standard-1" # 1 CPU, 2GB RAM, adjust as needed
}

# Resource: Create a Linode instance
resource "linode_instance" "example_instance" {
  label           = "jenkins-example-instance"
  region          = var.region
  type            = var.instance_type
  image           = "linode/ubuntu20.04" # Ubuntu 20.04 image, adjust as needed
  root_pass       = "SecureRootPassword123!" # Replace with a secure password or use a random generator
  authorized_keys = ["ssh-rsa YOUR_PUBLIC_SSH_KEY_HERE"] # Replace with your SSH public key
}

# Output the instance IP for use in Ansible or debugging
output "instance_ip" {
  description = "Public IP address of the Linode instance"
  value       = linode_instance.example_instance.ip_address
}
