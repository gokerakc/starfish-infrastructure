terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
     key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = var.rg_name
  location = var.location
}

module "keyvault" {
  source = "./modules/keyvault"
  keyvault_name = var.keyvault_name
  location = var.location
  rg_name = var.rg_name

  depends_on = [
    azurerm_resource_group.rg1
  ]
  
}

resource "azurerm_key_vault_secret" "initial" {
  name         = "Initial--Secret"
  value        = "InitialSecret"
  key_vault_id = module.keyvault.keyvault_id

  depends_on = [
    module.keyvault
  ]
}

resource "azurerm_virtual_network" "aksvnet" {
  name = "aks-network"
  location = var.location
  resource_group_name = var.rg_name
  address_space = ["10.0.0.0/8"]

  depends_on = [
    azurerm_resource_group.rg1
  ]
}

resource "azurerm_subnet" "aks-default" {
  name = "aks-default-subnet"
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name = var.rg_name
  address_prefixes = ["10.240.0.0/16"]

  depends_on = [
    azurerm_virtual_network.aksvnet
  ]
}

module "aks" {
  source = "./modules/aks/"
  location = var.location
  rg_name = var.rg_name
  environment = var.environment
  ssh_public_key = var.ssh_signing_key
  subnet_id = azurerm_subnet.aks-default.id

  depends_on = [
    azurerm_subnet.aks-default
  ]
}