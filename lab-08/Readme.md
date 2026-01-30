**Lab 8 is where everything you built so far finally comes together for AKS** 🚀
I’ll go **slow, complete, and very explicit**, because AKS networking is where most people get confused.

I’ll give you:

* 🎯 What Lab 8 is really about
* 📁 Final folder structure
* 📄 **ALL files** (root + modules)
* 🧠 Deep explanation of *why each decision exists*
* 🔥 AKS-specific networking rules you must remember

No Terragrunt yet — pure Terraform mastery first.

---

# 🧠 LAB 8 – AKS Networking (Deep, Practical Explanation)

---

## 🎯 Goal of Lab 8

You will deploy:

* An **AKS cluster**
* Into a **custom VNet**
* Using a **dedicated subnet**
* With correct Azure networking rules

This is **production-style AKS**, not default wizard stuff.

---

## 🧠 Mental Model (Critical)

AKS networking has **3 layers**:

1. **Azure networking**

   * VNet
   * Subnets
   * NSGs

2. **AKS cluster**

   * Control plane (managed by Azure)
   * Node pools (VMSS)

3. **Pod networking**

   * Azure CNI
   * Pod IPs come from subnet

👉 AKS does **NOT** create networking for you when using custom VNet
👉 Terraform must do it *before* AKS

---

# 📁 Lab-08 Folder Structure

```
lab-08/
├── root/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── versions.tf
│
└── modules/
    ├── network/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── aks/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

We **reuse the network module** and add a **new AKS module**.

---

# 🟢 ROOT MODULE (Orchestrator)

Root:

* Creates RG
* Calls network
* Passes subnet to AKS

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

---

## 📄 `root/providers.tf`

```hcl
provider "azurerm" {
  features {}
}
```

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

---

## 📄 `root/main.tf`

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
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

module "aks" {
  source = "../modules/aks"

  rg_name   = azurerm_resource_group.this.name
  location  = var.location
  subnet_id = module.network.subnet_ids["aks"]

  environment = var.environment
  common_tags = var.common_tags
}
```

🧠 Key idea:

* Network module runs **first**
* AKS consumes **only the AKS subnet**
* No hardcoding

---

## 📄 `root/outputs.tf`

```hcl
output "aks_cluster_name" {
  value = module.aks.cluster_name
}
```

---

# 🔵 NETWORK MODULE (AKS-Ready Networking)

(Same as Lab 7, but we’ll explain AKS relevance)

---

## 📄 `modules/network/main.tf` (Key Points Only)

```hcl
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]
}
```

🧠 Why this matters for AKS:

* AKS requires a **dedicated subnet**
* Subnet must have **enough IPs** for:

  * Nodes
  * Pods (Azure CNI)

Rule of thumb:

> `/24` minimum for small clusters

---

## 📄 `modules/network/outputs.tf`

```hcl
output "subnet_ids" {
  value = {
    for k, s in azurerm_subnet.this : k => s.id
  }
}
```

This is how AKS knows **where to live**.

---

# 🔴 AKS MODULE (The Star of Lab 8)

---

## 📄 `modules/aks/variables.tf`

```hcl
variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
```

---

## 📄 `modules/aks/main.tf`

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "aks-${var.environment}"

  default_node_pool {
    name           = "system"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = merge(
    var.common_tags,
    {
      environment = var.environment
    }
  )
}
```

---

## 🧠 DEEP AKS NETWORKING EXPLANATION

### 🔹 `network_plugin = "azure"`

This enables **Azure CNI**:

* Pods get **real IPs** from subnet
* Pods are reachable from VNet
* Required for:

  * Private endpoints
  * Enterprise networking

⚠️ Consumes **many IPs**

---

### 🔹 `vnet_subnet_id`

This is **mandatory** for custom VNet AKS.

What happens:

* AKS node pool VMSS attaches to subnet
* Azure assigns IPs for:

  * Nodes
  * Pods
  * Load balancers

---

### 🔹 Node Pool

```hcl
default_node_pool {
  name = "system"
}
```

* System pods run here
* Required pool
* User workloads can go to separate pools later (Lab 9)

---

### 🔹 Managed Identity

```hcl
identity {
  type = "SystemAssigned"
}
```

Azure automatically:

* Creates an identity
* Assigns permissions
* AKS uses it to:

  * Manage LB
  * Attach disks
  * Read subnet

---

## 📄 `modules/aks/outputs.tf`

```hcl
output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}
```

---

# ▶️ Example `terraform.tfvars`

```hcl
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
```

---

# ▶️ How to Run Lab 8

```bash
cd lab-08/root
terraform init
terraform plan
terraform apply
```

AKS takes **5–10 minutes** ⏳

---

# 🔥 AKS Networking Rules (Must Remember)

1. AKS subnet must be **dedicated**
2. Azure CNI consumes many IPs
3. Subnet size matters
4. Never overlap CIDRs
5. Network comes **before** AKS

---

# 🧠 What You Achieved in Lab 8

You now:

* Deploy **real AKS**
* Control networking
* Understand Azure CNI
* Are production-ready

---

## 🔜 Next Labs



* **Lab 9:** AKS node pools (system vs user)
* **Lab 10:** AKS + ACR integration
* **Lab 11:** Private AKS cluster
* **Lab 12:** Convert everything to Terragrunt 🔥


