remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaksdemo"
    container_name       = "tg-state"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}