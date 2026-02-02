**Lab 13 is where your AKS stops looking like a tutorial cluster and starts looking like something you’d actually run in production** 💪
This lab is all about **node pools as a design tool**, not just compute.

I’ll give you:

* Clear mental model
* Full Terraform solution
* Deep explanation of *why each pool exists*
* How upgrade works
* What to verify

---

# 🧠 Lab 13 – Advanced AKS Configuration (Node Pools)

## 🎯 Goal (Translated to Real Life)

You want:

* Separation of **system** and **workload** nodes
* Automatic scaling based on demand
* Cheap, interruptible compute for non-critical workloads
* Ability to upgrade node pools independently

🎯 **Deliverable**:

> A **multi-node-pool AKS cluster**

---

# 🧠 Mental Model (Very Important)

In AKS:

* **Cluster** = control plane (managed by Azure)
* **Node pools** = VM Scale Sets
* Each node pool:

  * Can scale independently
  * Can upgrade independently
  * Can have different VM types
  * Can be spot / regular

---

# 📁 Lab 13 Folder Structure

```
lab-13/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── versions.tf
```

(Simple on purpose — focus is AKS tuning.)

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
  default = "rg-lab-13"
}

variable "location" {
  default = "East US"
}

variable "cluster_name" {
  default = "aks-lab-13"
}

variable "kubernetes_version" {
  default = null
}
```

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

## 🔹 AKS Cluster (System Node Pool Only)

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.cluster_name

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_DS2_v2"
    node_count = 2
  }

  identity {
    type = "SystemAssigned"
  }
}
```

---

## 🧠 Why Only System Pool Here?

* System pool:

  * Runs CoreDNS
  * Runs kube-proxy
  * Runs Azure agents
* Should be:

  * Stable
  * Not spot
  * Not aggressively autoscaled

---

# 🔹 User Node Pool (Autoscaling)

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_DS2_v2"

  mode = "User"

  enable_auto_scaling = true
  min_count           = 1
  max_count           = 5

  node_labels = {
    workload = "general"
  }
}
```

---

## 🧠 Why User Pool + Autoscaling?

* Keeps workloads off system nodes
* Scales based on demand
* Kubernetes scheduler places pods here by default (unless constrained)

---

# 🔹 Spot Node Pool (Cheap Compute)

```hcl
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spotpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_DS2_v2"

  mode = "User"

  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = -1

  enable_auto_scaling = true
  min_count           = 0
  max_count           = 3

  node_labels = {
    workload = "spot"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
}
```

---

## 🧠 Why Spot Pool?

* Uses **unused Azure capacity**
* 70–90% cheaper
* Can be evicted anytime

### Why taints?

* Prevents critical workloads from landing here
* Only pods with tolerations can use spot nodes

---

# 🧠 Scheduling Example (Conceptual)

```yaml
tolerations:
- key: "kubernetes.azure.com/scalesetpriority"
  operator: "Equal"
  value: "spot"
  effect: "NoSchedule"
```

---

# 📄 `outputs.tf`

```hcl
output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}
```

---

# ▶️ Deploy the Cluster

```bash
terraform init
terraform apply
```

⏳ ~5–10 minutes

---

# 🔐 Connect to AKS

```bash
az aks get-credentials \
  --resource-group rg-lab-13 \
  --name aks-lab-13
```

---

# ✅ Validate Multi-Pool Cluster

```bash
kubectl get nodes -L workload
```

### Example output:

```text
NAME                                STATUS   ROLES   WORKLOAD
aks-system-xxxxx-vmss000000         Ready    agent
aks-userpool-xxxxx-vmss000000       Ready    agent   general
aks-spotpool-xxxxx-vmss000000       Ready    agent   spot
```

🎯 **Deliverable achieved**:

> Multi-pool AKS cluster

---

# 🔄 Perform Node Pool Upgrade

## Step 1: Check versions

```bash
az aks get-upgrades \
  --resource-group rg-lab-13 \
  --name aks-lab-13
```

---

## Step 2: Upgrade user pool only

```bash
az aks nodepool upgrade \
  --resource-group rg-lab-13 \
  --cluster-name aks-lab-13 \
  --name userpool \
  --kubernetes-version <new-version>
```

🧠 Why this matters:

* No control plane downtime
* System pool untouched
* Workloads migrate gradually

---

# 🧠 What You Learned in Lab 13

You now understand:

* System vs user node pools
* Autoscaling in AKS
* Spot instances
* Taints & tolerations
* Independent node pool upgrades

This is **real production AKS design**.

---

# 🔥 Common Interview Gold Lines

> “We isolate system workloads, use autoscaling user pools for apps, and spot pools for cost-optimized workloads with taints.”

That sentence alone sounds **senior-level** 😄

---


