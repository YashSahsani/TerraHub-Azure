terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {

  features {}
}

resource "azurerm_resource_group" "mtc-rg" {
  name     = "mtc-resource"
  location = "Canada Central"
  tags = {
    environment = "dev"
  }
}


resource "azurerm_virtual_network" "mtc-vn" {
  name                = "mtc-virtual-network"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  address_space       = ["10.10.1.0/24"]
  tags = {
    environment = "dev"
  }

}


resource "azurerm_subnet" "mtc-sn" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  virtual_network_name = azurerm_virtual_network.mtc-vn.name
  address_prefixes     = ["10.10.1.0/24"]

}


resource "azurerm_network_security_group" "mtc-sg" {
  name     = "mtc-security-group"
  location = azurerm_resource_group.mtc-rg.location

  resource_group_name = azurerm_resource_group.mtc-rg.name
  tags = {
    environment = "dev"
  }
}


resource "azurerm_network_security_rule" "mtc-dev-rule" {
  name                        = "mtc-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "70.31.101.151/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  network_security_group_name = azurerm_network_security_group.mtc-sg.name

}


resource "azurerm_subnet_network_security_group_association" "mtc-sga" {
  subnet_id                 = azurerm_subnet.mtc-sn.id
  network_security_group_id = azurerm_network_security_group.mtc-sg.id

}

resource "azurerm_public_ip" "mtc-pip" {
  name                = "mtc-public-ip"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  allocation_method   = "Dynamic"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "mtc-nic" {
  name                = "mtc-nic"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mtc-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc-pip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "mtc-lvm" {
  name                  = "mtc-linux-vm"
  resource_group_name   = azurerm_resource_group.mtc-rg.name
  location              = azurerm_resource_group.mtc-rg.location
  size                  = "Standard_B1s"
  admin_username        = "yashadmin"
  network_interface_ids = [azurerm_network_interface.mtc-nic.id]

  custom_data = filebase64("../templates/install-docker.tpl")

  admin_ssh_key {
    username   = "yashadmin"
    public_key = file("~/.ssh/xxx.pub") ## TODO change this path 
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("../templates/${var.host_os}-Create-Ssh-Config-Script.tpl", {
      hostname     = self.public_ip_address
      user         = "yashadmin"
      identityFile = "~/.ssh/xxx" ## TODO change this path
    })

    interpreter = var.host_os == "linux" ? ["/bin/bash", "-c"] : ["powershell.exe", "-Command"]
  }

  tags = {
    environment = "dev"
  }

}


data "azurerm_public_ip" "mtc-pip-data" {
  name                = azurerm_public_ip.mtc-pip.name
  resource_group_name = azurerm_resource_group.mtc-rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc-lvm.name}:${data.azurerm_public_ip.mtc-pip-data.ip_address}"

}