**Lab 12 is true production AKS territory** 🧱
This lab connects **AKS + Azure Monitor + real persistent storage**, which is exactly what real workloads need.

I’ll give you:

* Clear mental model
* Terraform changes (AKS add-ons)
* Kubernetes YAML for PVC
* Validation steps (kubectl + Azure Portal)
* Why each piece exists

---

# 🧠 Lab 12 – AKS Storage & Add-ons (Deep Explanation)

## 🎯 Goal (What You’re Actually Proving)

You want to prove that:

1. AKS can **send logs & metrics to Azure**
2. AKS workloads can **persist data**
3. Storage survives pod restarts

This lab answers:

> “Is this AKS cluster production-ready?”

---

# 🧠 Big Picture Architecture

```
AKS
 ├── Azure Monitor (addon)
 │    └── Log Analytics Workspace
 │
 └── Workload Pod
      └── PVC
           └── Azure Disk
```

---

# 📁 Lab 12 Folder Structure

```
lab-12/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── versions.tf
```

(We’ll deploy storage using **kubectl YAML**, not Terraform — this is best practice.)

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
  default = "rg-lab-12"
}

variable "location" {
  default = "East US"
}

variable "cluster_name" {
  default = "aks-lab-12"
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

## 🔹 Log Analytics Workspace

```hcl
resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.cluster_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```

🧠 Why this exists:

* Azure Monitor **needs** a workspace
* Stores:

  * Container logs
  * Node metrics
  * Kubernetes events

---

## 🔹 AKS Cluster with Azure Monitor Enabled

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

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }
}
```

---

## 🧠 DEEP EXPLANATION – Azure Monitor Add-on

### 🔹 `oms_agent`

This enables:

* Container Insights
* Node CPU / Memory
* Pod logs
* Cluster health

Azure:

* Installs monitoring agents as DaemonSets
* Sends data to Log Analytics
* No manual configuration needed

👉 This is **mandatory for production AKS**

---

# 📄 `outputs.tf`

```hcl
output "log_analytics_workspace" {
  value = azurerm_log_analytics_workspace.this.name
}
```

---

# ▶️ Deploy Infrastructure

```bash
terraform init
terraform apply
```

⏳ Wait ~5 minutes

---

# 🔐 Get AKS Credentials

```bash
az aks get-credentials \
  --resource-group rg-lab-12 \
  --name aks-lab-12
```

---

# 🧠 AKS Storage Model (Important)

### Azure Disk:

* Block storage
* Attached to **one node**
* Perfect for:

  * Databases
  * Stateful apps

AKS automatically installs:

* **CSI drivers** for Azure Disk
* Default `StorageClass`

---

# 📄 Deploy Persistent Storage (PVC)

## 📄 `pvc.yaml`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-disk-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-csi
  resources:
    requests:
      storage: 5Gi
```

Apply it:

```bash
kubectl apply -f pvc.yaml
```

---

## 🧠 What Happens Behind the Scenes

1. Kubernetes sees PVC
2. CSI driver provisions **Azure Managed Disk**
3. Disk attaches to a node
4. PVC becomes `Bound`

Check:

```bash
kubectl get pvc
```

Expected:

```text
azure-disk-pvc   Bound   pvc-xxxx   5Gi
```

---

# 📄 Deploy Test Pod Using PVC

## 📄 `pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: disk-test
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo hello > /data/hello.txt && sleep 3600"]
    volumeMounts:
    - mountPath: /data
      name: disk
  volumes:
  - name: disk
    persistentVolumeClaim:
      claimName: azure-disk-pvc
```

Apply:

```bash
kubectl apply -f pod.yaml
```

---

# ✅ Validate Persistent Storage

### Exec into pod:

```bash
kubectl exec -it disk-test -- cat /data/hello.txt
```

Output:

```text
hello
```

### Delete pod:

```bash
kubectl delete pod disk-test
```

### Recreate pod:

```bash
kubectl apply -f pod.yaml
```

### Check again:

```bash
kubectl exec -it disk-test -- cat /data/hello.txt
```

🎯 **Data still exists → persistent storage works**

---

# 🔍 Validate Azure Monitor (Portal)

1. Azure Portal → AKS → **Insights**
2. View:

   * Nodes
   * Pods
   * Logs
3. Go to **Log Analytics Workspace**
4. Run sample query:

```kusto
ContainerLog
| take 10
```

🎯 **Logs flowing successfully**

---

# ✅ Deliverables Achieved

✔ Azure Monitor enabled

✔ Log Analytics connected

✔ PVC created

✔ Azure Disk attached

✔ Data persisted

✔ Logs visible in Azure

---

# 🧠 What You Learned in Lab 12

You now know:

* How AKS monitoring works
* How CSI storage works
* Difference between ephemeral vs persistent
* Why Azure Disk is production-grade

This is **real-world AKS**.

---
