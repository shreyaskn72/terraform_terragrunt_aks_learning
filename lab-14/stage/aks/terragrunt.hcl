terraform {
  source = "../../../terraform/aks"
}

inputs = {
  resource_group_name = "rg-stage-aks"
  location            = "East US"
  cluster_name        = "aks-stage"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state-stage"
    storage_account_name = "tfstateaksdemo"
    container_name       = "stage"
    key                  = "aks.tfstate"
  }
}