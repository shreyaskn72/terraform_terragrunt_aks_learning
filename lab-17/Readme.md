This lab is 🔥 **core Terragrunt mastery**.

Once you understand **dependencies**, you stop “running Terraform in the right order” and start **designing systems**.

I’ll go step-by-step, explain **why**, **how**, and **what Terragrunt is doing behind the scenes**.

---

# 🧠 Lab 17 – Terragrunt Dependencies

**Goal: Ordered deployments with zero manual wiring**

---

## 🎯 What This Lab Is REALLY About

> One infrastructure component **needs outputs from another**
> Terragrunt should:
>
> * Deploy them in the right order
> * Pass values automatically
> * Prevent human mistakes

🎯 **Deliverable**:
👉 **Zero manual wiring**

---

# 🧠 Real-World Scenario (Very Common)

AKS **must** be deployed into a **VNet**.

That means:

* VNet → created first
* AKS → uses subnet ID from VNet

Without Terragrunt:

* You copy outputs manually
* Or hardcode IDs (dangerous)
* Or apply in the wrong order

Terragrunt solves this cleanly.

---

# 🧱 Final Folder Structure (What We’ll Build)

```
lab-17/
├── modules/
│   ├── vnet/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── versions.tf
│   │
│   └── aks/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── versions.tf
│
└── live/
    ├── terragrunt.hcl
    │
    └── dev/
        ├── vnet/
        │   └── terragrunt.hcl
        │
        └── aks/
            └── terragrunt.hcl
```

---

# 🧠 Dependency Flow (Important)

```
VNet  ───▶  AKS
```

* VNet produces `subnet_id`
* AKS consumes `subnet_id`
* Terragrunt enforces the order

---

# 🧩 Step 1: Terraform VNet Module

## 📄 `modules/vnet/main.tf`

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

---

## 📄 `modules/vnet/outputs.tf`

```hcl
output "subnet_id" {
  value = azurerm_subnet.aks.id
}
```

🧠 **This output is the contract**
Other modules depend on this.

---

# 🧩 Step 2: Update AKS Module to Accept Subnet ID

## 📄 `modules/aks/variables.tf`

```hcl
variable "subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
}
```

---

## 📄 `modules/aks/main.tf` (Networking Part)

```hcl
network_profile {
  network_plugin = "azure"
}

default_node_pool {
  name           = "system"
  vm_size        = "Standard_DS2_v2"
  node_count     = 2
  vnet_subnet_id = var.subnet_id
}
```

🧠 AKS is now **dependent on the VNet**, but Terraform alone does NOT control order.

---

# 🧠 Step 3: Root Terragrunt Config

## 📄 `live/terragrunt.hcl`

```hcl
remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaksdemo"
    container_name       = "tg-state"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
```

---

# 🧠 Step 4: VNet Terragrunt Config

## 📄 `live/dev/vnet/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vnet"
}

inputs = {
  resource_group_name = "rg-dev-network"
  location            = "East US"
}
```

🧠 VNet has **no dependencies** — it’s foundational.

---

# 🧠 Step 5: AKS Terragrunt Config (THE KEY PART)

## 📄 `live/dev/aks/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

dependency "vnet" {
  config_path = "../vnet"
}
```

### 🧠 What This Does

* Tells Terragrunt:

  > “AKS depends on the VNet in this folder”
* Reads outputs from VNet’s state
* Enforces deployment order

---

## 🔹 Use Dependency Output as Input

```hcl
terraform {
  source = "../../../modules/aks"
}

inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"

  subnet_id = dependency.vnet.outputs.subnet_id
}
```

🧠 **Zero manual wiring**
No copy-paste
No hardcoding
No guessing IDs

---

# ▶️ Step 6: Apply (Correct Order Automatically)

From `live/dev`:

```bash
terragrunt run-all apply
```

🧠 Terragrunt does:

1. Builds dependency graph
2. Applies VNet first
3. Reads subnet_id
4. Applies AKS next

You didn’t control order — **Terragrunt did**.

---

# ✅ Verify Deliverable

* VNet created
* Subnet created
* AKS deployed into subnet
* No manual wiring

🎯 **Deliverable achieved**:

> Zero manual wiring

---

# 🧠 Why This Is a Big Deal

| Without Dependencies | With Terragrunt |
| -------------------- | --------------- |
| Manual order         | Automatic       |
| Hardcoded IDs        | Dynamic         |
| Fragile              | Safe            |
| Human errors         | None            |

---

# 🔥 Interview-Level Explanation

> “We use Terragrunt dependency blocks to model infrastructure relationships and automatically pass outputs between modules.”

That sentence alone = **senior DevOps signal** 🚀

---

# 🧭 Common Beginner Mistakes

❌ Using `terraform_remote_state` manually

❌ Hardcoding subnet IDs

❌ Applying folders individually

❌ Circular dependencies

---

# 🎉 Congratulations!
