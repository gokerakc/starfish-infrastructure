# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "starfish" {
  name     = "starfish-resources"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "starfish" {
  name                = "starfish-network"
  resource_group_name = azurerm_resource_group.starfish.name
  location            = azurerm_resource_group.starfish.location
  address_space       = ["10.0.0.0/16"]
}

# Create subnet
resource "azurerm_subnet" "starfish" {
  name = "starfish-subnet"
  virtual_network_name = azurerm_virtual_network.starfish.name
  resource_group_name = azurerm_resource_group.starfish.name
  address_prefixes = ["10.0.0.0/24"]
}

# Create network interface card (NIC)
resource "azurerm_network_interface" "internal" {
  name = "internal-nic"
  location = azurerm_resource_group.starfish.location
  resource_group_name = azurerm_resource_group.starfish.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.starfish.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "starfish" {
  name = "starfish-vm"
  resource_group_name = azurerm_resource_group.starfish.name
  location = azurerm_resource_group.starfish.location
  size = "Standard_B1s"
  admin_username = "user.admin"
  admin_password = "<PLACEHOLDER>"

  network_interface_ids = [azurerm_network_interface.internal.id]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "user.admin"
    public_key = file("C:/Users/goker/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
  
}