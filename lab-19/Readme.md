**Lab 19 is a big step up**. This is where AKS stops being “demo-grade” and starts looking **enterprise-secure** 🔐
I’ll keep it **hands-on, Terragrunt-friendly, and very explicit about *why* each setting exists**.

---

# 🧪 Lab 19: AKS Security Hardening

## 🎯 Goal

Secure AKS by:

* Deploying a **Private AKS cluster**
* Enabling **network policies**
* Restricting **API server access**

---

## 🧠 What “Secure AKS” Actually Means

In real orgs:

| Risk                        | Mitigation                              |
| --------------------------- | --------------------------------------- |
| Public Kubernetes API       | Private AKS                             |
| Pods talk to anything       | Network policies                        |
| Anyone on internet hits API | Authorized IP ranges / Private endpoint |
| Flat network                | VNet + subnet isolation                 |

This lab addresses **all of that**.

---

## 📁 Folder Structure (Same Pattern as Lab 18)

```
lab-19/
├── modules/
│   └── aks/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── live/
│   └── prod/
│       └── aks/
│           └── terragrunt.hcl
│
└── terragrunt.hcl
```

> ⚠️ **Private AKS is usually enabled only for prod**, so we’ll focus on `prod`.

---

## 1️⃣ AKS Module – Security-Hardened

### `modules/aks/main.tf`

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  # 🔒 PRIVATE CLUSTER
  private_cluster_enabled = true

  default_node_pool {
    name           = "system"
    vm_size        = var.system_node_vm_size
    node_count     = var.system_node_count
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # 🔐 NETWORK HARDENING
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"   # Enables Network Policies
    load_balancer_sku = "standard"
  }

  # 🔐 API SERVER ACCESS RESTRICTION
  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ips
  }
}
```

---

### 🔍 What’s Happening Here (Very Important)

#### ✅ `private_cluster_enabled = true`

* AKS API **no longer exposed to internet**
* API reachable **only inside VNet**
* Azure creates:

  * Private Endpoint
  * Private DNS Zone

This is **mandatory for regulated environments**.

---

#### ✅ `network_policy = "azure"`

* Enables **Kubernetes NetworkPolicies**
* Allows you to control:

  * Pod-to-Pod traffic
  * Namespace isolation
* Without this → all pods can talk freely (bad)

---

#### ✅ `api_server_access_profile`

* Restricts *who* can talk to Kubernetes API
* Even private clusters need this
* Common patterns:

  * Corporate VPN IPs
  * Jumpbox subnet IPs

---

## 2️⃣ AKS Module Variables

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

variable "subnet_id" {
  type = string
}

variable "api_server_authorized_ips" {
  type        = list(string)
  description = "IP ranges allowed to access AKS API server"
}
```

---

## 3️⃣ Outputs (Minimal but Useful)

### `modules/aks/outputs.tf`

```hcl
output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "private_fqdn" {
  value = azurerm_kubernetes_cluster.this.private_fqdn
}
```

---

## 4️⃣ Root Terragrunt (Same as Before)

### `lab-19/terragrunt.hcl`

```hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateakssecure"
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

---

## 5️⃣ Prod AKS Terragrunt Config (Private & Secure)

### `live/prod/aks/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

dependency "network" {
  config_path = "../../network"
}

inputs = {
  cluster_name        = "aks-prod-private"
  resource_group_name = "rg-aks-prod"
  location            = "eastus"

  system_node_vm_size = "Standard_DS3_v2"
  system_node_count   = 3

  subnet_id = dependency.network.outputs.aks_subnet_id

  api_server_authorized_ips = [
    "203.0.113.10/32"   # VPN / jumpbox IP
  ]
}
```

---

## 6️⃣ How You Deploy

```bash
cd live/prod/aks
terragrunt apply
```

---

## 7️⃣ Validation (Critical for This Lab)

### 🔍 1. Check AKS is Private

```bash
az aks show \
  --name aks-prod-private \
  --resource-group rg-aks-prod \
  --query privateCluster.enabled
```

✅ Should return `true`

---

### 🔍 2. Try Accessing API Outside VNet

```bash
kubectl get nodes
```

❌ Will fail unless:

* You are on VPN
* Or inside VNet
* Or using a jumpbox

This is **expected** and **good**.

---

### 🔍 3. Validate Network Policies

```bash
kubectl get networkpolicy --all-namespaces
```

You can now **enforce traffic rules** (was impossible before).

---

## ✅ Deliverable Achieved

✔ Private AKS cluster
✔ No public API endpoint
✔ Network policies enabled
✔ API access restricted
✔ Production-grade security

---

## 🧠 Why This Lab Is Extremely Important

You now understand:

* Why public AKS is dangerous
* How Azure Private AKS works internally
* How Terragrunt keeps this clean per environment
* How security is enforced *by design*, not by luck

This is **senior-level AKS knowledge**.

---

## private AKS traffic flow:

![Private AKS Diagram](.private_aks.png)