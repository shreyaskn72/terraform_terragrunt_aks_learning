terraform {
  source = "../../../terraform/aks"
}

inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaksdemo"
    container_name       = "dev"
    key                  = "aks.tfstate"
  }
}