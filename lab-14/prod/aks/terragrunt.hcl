terraform {
  source = "../../../terraform/aks"
}

inputs = {
  resource_group_name = "rg--aks--prod"
  location            = "East US"
  cluster_name        = "aks-prod"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state--prod"
    storage_account_name = "tfstateaksdemo"
    container_name       = "prod"
    key                  = "aks.tfstate"
  }
}