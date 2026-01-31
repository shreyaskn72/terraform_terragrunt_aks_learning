Perfect 👍 — you’re following the flow exactly as intended.
**Lab 10 is your “hello world” AKS lab**: minimal, clean, and confidence-building.

We will write:

* Clear goal mapping
* Minimal but correct Terraform
* Step-by-step commands
* Exactly how to verify the deliverable

No extra complexity yet (no networking tricks, no Terragrunt).

---

# 🧪 Lab 10 – Basic AKS Cluster (First Working AKS)

## 🎯 Goal

Deploy a **basic AKS cluster** and prove:

* The cluster exists
* The **system node pool** is running
* You can connect using `kubectl`

---

## 🧠 What “Basic AKS” Means Here

For this lab:

* Use **default AKS networking** (Azure CNI default)
* Single **system node pool**
* Public API server
* No custom VNet yet

This keeps focus on:

> “Can I deploy and talk to AKS?”

---

# 📁 Folder Structure

```
lab-10/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── versions.tf
```

👉 No modules yet
👉 Flat structure on purpose

---

# 📄 `versions.tf`

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

# 📄 `providers.tf`

```hcl
provider "azurerm" {
  features {}
}
```

---

# 📄 `variables.tf`

```hcl
variable "resource_group_name" {
  type    = string
  default = "rg-lab-10"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "cluster_name" {
  type    = string
  default = "aks-lab-10"
}
```

---

# 📄 `main.tf`

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "system"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
```

### 🧠 Explanation (Key Points)

* **`default_node_pool`**

  * This is the **system node pool**
  * Mandatory for AKS
* **`SystemAssigned` identity**

  * AKS manages Azure resources automatically
* No networking block:

  * AKS uses **default Azure CNI**
  * Azure creates VNet automatically

---

# 📄 `outputs.tf`

```hcl
output "aks_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "resource_group" {
  value = azurerm_resource_group.this.name
}
```

---

# ▶️ Deploy the Cluster

```bash
terraform init
terraform apply
```

⏳ AKS creation: ~5 minutes

---

# 🔐 Connect to AKS

```bash
az aks get-credentials \
  --resource-group rg-lab-10 \
  --name aks-lab-10
```

This:

* Downloads kubeconfig
* Merges it into `~/.kube/config`
* Sets current context

---

# ✅ Deliverable Verification

```bash
kubectl get nodes
```

### Example output:

```text
NAME                                STATUS   ROLES   AGE   VERSION
aks-system-12345678-vmss000000      Ready    agent   2m    v1.29
aks-system-12345678-vmss000001      Ready    agent   2m    v1.29
```

🎯 **Deliverable achieved**:

> `kubectl get nodes` works

---

# 🧠 Common Issues & Fixes

### ❌ `kubectl: command not found`

👉 Install kubectl:

```bash
az aks install-cli
```

---

### ❌ `Unauthorized`

👉 Run:

```bash
az login
az account set --subscription <sub-id>
```

---

# 🧠 What You Learned in Lab 10

You can now:

* Deploy AKS with Terraform
* Understand system node pool
* Authenticate to AKS
* Use kubectl successfully

This is the **foundation** for everything next.

---


