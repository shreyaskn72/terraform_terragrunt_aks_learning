resource_group_name = "rg-lab-08"
environment         = "dev"

common_tags = {
  project = "aks-learning"
  owner   = "shreyas"
}

subnets = {
  aks = {
    address_prefix = "10.0.1.0/24"
  }
}

nsg_rules = {}