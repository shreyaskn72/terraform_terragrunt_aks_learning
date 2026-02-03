Love this lab — this is where your setup starts to look like a **real company repo** 👌

I’ll walk you through **Lab 18: Multi-Environment AKS** step-by-step, explain *why* each thing exists, and keep it consistent with everything you’ve already learned (Labs 14–17).

---

# 🧪 Lab 18: Multi-Environment AKS

## 🎯 Goal

Deploy **Dev** and **Prod** AKS clusters using:

* Same Terraform modules
* Terragrunt for orchestration
* Different configurations (node sizes, scaling, etc.)

👉 This is exactly how real orgs avoid copy-paste disasters.

---

## 🧠 Key Idea of This Lab

> **Terraform modules define *what* to build**
> **Terragrunt defines *where* and *how* it’s deployed**

So:

* **One AKS module**
* **Multiple environments**
* **Different inputs per environment**

---

## 📁 Final Folder Structure (Industry-Standard)

```
lab-18/
├── modules/
│   └── aks/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── live/
│   ├── dev/
│   │   └── aks/
│   │       └── terragrunt.hcl
│   │
│   └── prod/
│       └── aks/
│           └── terragrunt.hcl
│
└── terragrunt.hcl   # root config (shared)
```

---

## 1️⃣ AKS Terraform Module (Reusable Core)

### `modules/aks/main.tf`

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "system"
    vm_size    = var.system_node_vm_size
    node_count = var.system_node_count
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}
```

### Why this is correct

* No environment logic
* No backend
* No provider
* Everything configurable via variables

---

### `modules/aks/variables.tf`

```hcl
variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "system_node_vm_size" {
  type = string
}

variable "system_node_count" {
  type = number
}
```

---

### `modules/aks/outputs.tf`

```hcl
output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}
```

---

## 2️⃣ Root Terragrunt Config (Shared by All Envs)

### `lab-18/terragrunt.hcl`

```hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateaksorg"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}
```

### 🔍 Why this matters

* **Single backend definition**
* **State isolation per environment**
* `key` auto-separates dev/prod states

---

## 3️⃣ Dev AKS (Smaller, Cheaper)

### `live/dev/aks/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  cluster_name          = "aks-dev"
  resource_group_name   = "rg-aks-dev"
  location              = "eastus"

  system_node_vm_size   = "Standard_DS2_v2"
  system_node_count     = 1
}
```

### Why Dev is different

* Smaller VM
* Fewer nodes
* Lower cost
* Faster experimentation

---

## 4️⃣ Prod AKS (Bigger & Safer)

### `live/prod/aks/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  cluster_name          = "aks-prod"
  resource_group_name   = "rg-aks-prod"
  location              = "eastus"

  system_node_vm_size   = "Standard_DS3_v2"
  system_node_count     = 3
}
```

### Why Prod is different

* Larger nodes
* More replicas
* Higher availability
* Safer upgrades

---

## 5️⃣ How You Deploy (This Is the Magic ✨)

### Deploy Dev

```bash
cd live/dev/aks
terragrunt apply
```

### Deploy Prod

```bash
cd live/prod/aks
terragrunt apply
```

Each command:

* Uses same module
* Uses different inputs
* Uses different state file
* Creates **independent AKS clusters**

---

## ✅ Deliverable Check

✔ Dev AKS created
✔ Prod AKS created
✔ Different node sizes
✔ Same Terraform code
✔ Safe, isolated state

Run:

```bash
az aks list -o table
```

You should see **two clusters** 🎉

---

## 🧠 Why This Is “Real Org Setup”

This pattern gives you:

| Problem              | Solved by               |
| -------------------- | ----------------------- |
| Copy-paste Terraform | Modules                 |
| Env isolation        | Terragrunt folders      |
| State collisions     | Path-based backend key  |
| Scaling envs         | Inputs only             |
| Safe prod            | Separate state & config |

This is **exactly** how:

* Startups
* Enterprises
* Platform teams
  manage AKS at scale.

---

## 🎉 Congrats!