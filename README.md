# TerraHub-Azure

## Overview
**TerraHub-Azure** is a Terraform-based automation project that provisions an Azure environment with a secure virtual network, resource group, and a Linux VM. The VM is pre-configured with Docker, enabling easy deployment of containerized applications on Azure. This setup provides both SSH and Docker-ready access, allowing for fast and scalable cloud infrastructure setup.

## Features
- **Azure Resource Group & Networking**: Creates a resource group, virtual network, subnet, and network security group in Azure.
- **Docker-Enabled VM**: Deploys an Ubuntu Linux virtual machine with Docker installed, ready for container management.
- **SSH Configuration**: Provides automatic SSH setup for secure remote access.
  
## Requirements
- **Terraform**: v1.0+
- **Azure CLI**: Logged in and configured for your Azure account.
- **SSH Key**: Pre-generated SSH key for VM access.

## Project Structure
```plaintext
|-- terraform
    |-- dev.tfvars
    |-- main.tf                 # Main Terraform configuration
    |-- variables.tf            # Variables for Terraform
|--- templates
    |-- install-docker.tpl          # Cloud-init file for VM Docker setup
    |-- linux-Create-Ssh-Config-Script.tpl     # Template for SSH config script for linux
    |-- windows-Create-Ssh-Config-Script.tpl    # Template for SSH config script for windows
|-- README.md               # Project documentation
```
## Configure Terraform Variables
Edit variables.tf to set your host OS or other variables as needed:

```hcl
variable "host_os" {
  description = "The host OS of the machine"
  type        = string
  default     = "linux" # Change to your host OS if different
}
```

## Prerequisite
- Generate ssh key pair
```bash
cd terraform/
ssh-keygen -t rsa 
```
## Run Terraform Commands
1) Initialize Terraform:
```bash
terraform init
```
2) Plan the infrastructure:
```bash
terraform plan
```
3) Apply the configuration to deploy:
```bash
terraform apply -var-file="dev.tfvars" -auto-approve
```
4) Access the VM
- Use the public IP output by Terraform to SSH into the VM:
```bash
ssh -i /path/to/your/privatekey username@public_ip
```

## Configuration Details

This project deploys a Linux VM with:

- Docker: Installed and ready to use for container management.
- Network Security: Configured NSG rules to allow SSH access from specified IPs only.
- Custom SSH Configuration: Auto-generated SSH configuration file for secure and convenient access.

## Future Enhancements

- Add support for Azure Key Vault to manage sensitive data.
- Enable automatic updates and monitoring for Docker containers.
