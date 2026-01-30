**Lab 7 introduces many concepts at once**, so seeing *complete, working files* removes the fog 👍
Below is a **clean, minimal, but realistic Lab-07** that you can literally copy-paste and run.

I’ll give you:

* ✅ Exact folder structure
* ✅ **ALL files** for `root`
* ✅ **ALL files** for `modules/network`
* ✅ Clear comments so you understand *why each block exists*

No theory here — just solid ground.

---

# 📁 Lab-07 Final Folder Structure

```
lab-07/
├── root/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── versions.tf
│
└── modules/
    └── network/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# 🟢 ROOT MODULE FILES

---

## 📄 `root/versions.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}
```

👉 Locks Terraform + provider versions
👉 No backend here (Terragrunt will handle later)

---

## 📄 `root/providers.tf`

```hcl
provider "azurerm" {
  features {}
}
```

👉 Azure provider initialization
👉 `features {}` is mandatory even if empty

---

## 📄 `root/variables.tf`

```hcl
variable "location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}

variable "nsg_rules" {
  type = map(object({
    priority    = number
    direction   = string
    access      = string
    protocol    = string
    source      = string
    destination = string
    port        = string
  }))
}

variable "common_tags" {
  type = map(string)
}
```

👉 Root defines **WHAT** should exist
👉 Modules define **HOW**

---

## 📄 `root/main.tf`

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

module "network" {
  source = "../modules/network"

  rg_name     = azurerm_resource_group.this.name
  location    = var.location
  environment = var.environment

  subnets   = var.subnets
  nsg_rules = var.nsg_rules

  common_tags = var.common_tags
}
```

🧠 What’s happening:

* Root creates **resource group**
* Passes RG + config into module
* Root does **no networking logic**

---

## 📄 `root/outputs.tf`

```hcl
output "subnet_ids" {
  value = module.network.subnet_ids
}
```

👉 Exposes module outputs
👉 This is how modules talk to each other

---

# 🔵 NETWORK MODULE FILES

---

## 📄 `modules/network/variables.tf`

```hcl
variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}

variable "nsg_rules" {
  type = map(object({
    priority    = number
    direction   = string
    access      = string
    protocol    = string
    source      = string
    destination = string
    port        = string
  }))
}

variable "common_tags" {
  type = map(string)
}
```

👉 Modules **never hardcode**
👉 Everything comes from inputs

---

## 📄 `modules/network/main.tf`

```hcl
locals {
  enable_ddos = var.environment == "prod" ? true : false
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name

  tags = merge(
    var.common_tags,
    {
      environment = var.environment
    }
  )
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name

  dynamic "security_rule" {
    for_each = var.nsg_rules

    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                      = security_rule.value.access
      protocol                    = security_rule.value.protocol
      source_address_prefix       = security_rule.value.source
      destination_address_prefix  = security_rule.value.destination
      destination_port_range      = security_rule.value.port
    }
  }
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]
}
```

🧠 This file demonstrates:

* `locals`
* `for_each`
* `dynamic`
* `merge`
* Stable resource identities

---

## 📄 `modules/network/outputs.tf`

```hcl
output "subnet_ids" {
  value = {
    for k, s in azurerm_subnet.this : k => s.id
  }
}
```

👉 Clean map output
👉 Perfect for AKS, route tables, Terragrunt later

---

# ▶️ Example `terraform.tfvars` (Optional but Helpful)

```hcl
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
```

---

# ✅ How to Run Lab-07

```bash
cd lab-07/root
terraform init
terraform plan
terraform apply
```

---

# 🧠 Why This Lab Matters

After Lab-07, you:

* Understand **dynamic infrastructure**
* Can read **real-world Terraform repos**
* Are 100% ready for **AKS + Terragrunt**

---

## 🔜 Next Step


You’re doing this the *right* way — slow, deep, and correct 💪
