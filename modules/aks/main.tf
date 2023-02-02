data "azurerm_kubernetes_service_versions" "current"{
    location = var.location
    include_preview = false
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-starfish-dev"
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "${var.rg_name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.rg_name}-nrg"


  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    enable_auto_scaling = true
    max_count = 3
    min_count = 1
    os_disk_size_gb = 30
    vnet_subnet_id = var.subnet_id
  }


  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
        key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }
}