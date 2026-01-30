resource_group_name = "rg-lab-07"
environment         = "dev"

common_tags = {
  project = "terraform-aks"
  owner   = "shreyas"
}

subnets = {
  aks = {
    address_prefix = "10.0.1.0/24"
  }
  app = {
    address_prefix = "10.0.2.0/24"
  }
}

nsg_rules = {
  allow_ssh = {
    priority    = 100
    direction   = "Inbound"
    access      = "Allow"
    protocol    = "Tcp"
    source      = "*"
    destination = "*"
    port        = "22"
  }
}
