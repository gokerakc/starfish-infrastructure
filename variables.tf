variable "rg_name"{
    type = string
    description = "Resource group name."
}

variable "location" {
    type = string
    default = "UK South"
}

variable "service_principal_name" {
    type = string  
}

variable "subscription_path" {
    type = string
}

variable "keyvault_name" {
  type = string
}

variable "environment" {
  type = string  
  description = "This variable defines the Environment"  
  default = "dev"
}

variable "ssh_signing_key" {
  type = string
  description = "You can find your public key in this location -> ~/.ssh/id_rsa.pub"
}