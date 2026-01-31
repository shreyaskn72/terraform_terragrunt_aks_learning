**Lab 11 is where AKS stops being “a demo cluster” and becomes “secure infrastructure”** 🔐

I’ll walk you through this **slowly, end-to-end**, and explain *what Azure and Kubernetes are doing behind the scenes*.

---

# 🧠 Lab 11 – AKS Identity & RBAC (Deep Explanation)

## 🎯 Goal (Translated to Real Meaning)

You want:

* AKS to **authenticate via Azure AD**
* AKS to **authorize via Azure RBAC**
* Users to **only do what they’re allowed to**
* Proof using `kubectl auth can-i`

This lab answers:

> “Who are you?” and “What are you allowed to do?”

---

## 🧠 Big Picture (VERY IMPORTANT)

There are **two RBAC layers** in AKS:

### 1️⃣ Azure RBAC (Identity layer)

* Who can access the cluster
* Managed via Azure AD
* Controlled with Azure role assignments

### 2️⃣ Kubernetes RBAC (Authorization layer)

* What actions are allowed inside Kubernetes
* Enforced *after* authentication

👉 In this lab, we **bind Azure RBAC → Kubernetes RBAC**

---

# 📁 Lab 11 Folder Structure

```
lab-11/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── versions.tf
```

(Simple on purpose — focus is **security**, not modules.)

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
  default = "rg-lab-11"
}

variable "location" {
  default = "East US"
}

variable "cluster_name" {
  default = "aks-lab-11"
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for AKS admins"
  type        = list(string)
}
```

🧠 Why groups, not users?

* Users change
* Groups scale
* This is **enterprise best practice**

---

# 📄 `main.tf`

## 🔹 Resource Group

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}
```

---

## 🔹 AKS Cluster (Identity + RBAC Enabled)

```hcl
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

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }
}
```

---

# 🧠 DEEP EXPLANATION (THIS IS THE CORE)

---

## 🔐 1️⃣ Managed Identity

```hcl
identity {
  type = "SystemAssigned"
}
```

What happens:

* Azure creates an identity **tied to the AKS resource**
* AKS uses it to:

  * Create load balancers
  * Attach disks
  * Read VNet resources

👉 No secrets
👉 No service principals
👉 Azure rotates credentials automatically

---

## 🔑 2️⃣ Enable RBAC

```hcl
role_based_access_control_enabled = true
```

This turns on **Kubernetes RBAC**.

Without this:

* Everyone with cluster access is effectively admin 😱

---

## 🧠 3️⃣ Azure AD Integration (CRITICAL)

```hcl
azure_active_directory_role_based_access_control {
  managed                = true
  admin_group_object_ids = var.admin_group_object_ids
  azure_rbac_enabled     = true
}
```

This block does **a lot**:

### 🔹 `managed = true`

* AKS manages Azure AD integration
* No manual webhook setup

### 🔹 `admin_group_object_ids`

* Only these Azure AD groups get **cluster-admin**
* Everyone else is restricted

### 🔹 `azure_rbac_enabled = true`

* Azure roles map to Kubernetes roles
* Example:

  * Azure Kubernetes Service RBAC Viewer
  * Azure Kubernetes Service RBAC Writer
  * Azure Kubernetes Service RBAC Admin

---

# 📄 `outputs.tf`

```hcl
output "aks_name" {
  value = azurerm_kubernetes_cluster.this.name
}
```

---

# ▶️ Deploy the Cluster

```bash
terraform init
terraform apply
```

⏳ AKS creation: ~5–8 minutes

---

# 🔐 Get AKS Credentials (AAD Aware)

```bash
az aks get-credentials \
  --resource-group rg-lab-11 \
  --name aks-lab-11
```

🧠 What happens:

* Azure checks your Azure AD identity
* Issues a token
* kubectl uses that token

---

# 👤 Assign User Access (Azure RBAC)

## Example: Read-only access

```bash
az role assignment create \
  --assignee <USER_OBJECT_ID> \
  --role "Azure Kubernetes Service RBAC Viewer" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-lab-11/providers/Microsoft.ContainerService/managedClusters/aks-lab-11
```

🧠 This maps to Kubernetes permissions automatically.

---

# 🧪 TEST – RBAC Enforcement

### Command:

```bash
kubectl auth can-i get pods
```

### Expected results:

| Role    | Output |
| ------- | ------ |
| Viewer  | `yes`  |
| Writer  | `yes`  |
| No role | `no`   |
| Admin   | `yes`  |

🎯 **Deliverable achieved**:

> RBAC enforced

---

# 🔍 Test Denied Action

```bash
kubectl auth can-i delete pods
```

Viewer should see:

```text
no
```

✅ Proof of least privilege.

---

# 🧠 Common Mistakes (And Why They Hurt)

❌ Using local Kubernetes RBAC + AAD
❌ Giving everyone admin
❌ Using service principals
❌ Not testing permissions

You avoided all of these 🎉

---

# 🧠 What You Learned in Lab 11

You now understand:

* Managed Identity
* Azure AD integration
* Azure RBAC vs Kubernetes RBAC
* Secure AKS access
* Permission testing

This is **production-grade security**.

---
