**Lab 9 is short in tasks but very important conceptually**.
This lab answers a question interviewers *love*:

> *“How do pods get IPs in AKS?”*

Let’s do this cleanly and without confusion.

---

# 🧠 Lab 9 – AKS Networking Model (Azure CNI)

## 🎯 Goal (Rephrased Clearly)

You will:

* Deploy AKS **using Azure CNI**
* Verify that:

  * Nodes have VNet IPs
  * Pods also receive **VNet IPs**
* Prove it using `kubectl`

---

## 🧠 First: What Is Azure CNI (Simple Mental Model)

### With **Azure CNI**:

* Every **node** gets an IP from the subnet
* Every **pod** also gets an IP from the *same subnet*
* Pods are **first-class citizens** in the VNet

This is why:

* Pods can talk directly to VMs
* Pods can reach private endpoints
* Enterprises prefer Azure CNI

⚠️ Downside: **Consumes many IPs**

---

# 📁 Folder Structure (Same as Lab 8)

We’ll **reuse Lab 8** and only confirm Azure CNI explicitly.

```
lab-09/
├── root/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── versions.tf
│
└── modules/
    ├── network/
    └── aks/
```

👉 **No structural change**
👉 Only AKS networking matters here

---

# 🔴 AKS MODULE (Azure CNI Explicit)

This is the **only place that matters for Lab 9**.

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

  tags = var.common_tags
}
```

---

## 🧠 Why This Is Azure CNI (Critical)

This block makes it Azure CNI 👇

```hcl
network_profile {
  network_plugin = "azure"
}
```

Meaning:

* Azure manages pod networking
* Pod IPs come from **VNet subnet**
* `kubenet` is NOT used

---

# ▶️ Deploy AKS

```bash
cd lab-09/root
terraform init
terraform apply
```

⏳ Wait ~5–10 minutes

---

# 🔐 Get AKS Credentials

```bash
az aks get-credentials \
  --resource-group rg-lab-09 \
  --name aks-dev
```

---

# ✅ Validation Step (Very Important)

### Command:

```bash
kubectl get nodes -o wide
```

### Example Output:

```text
NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   OS-IMAGE
aks-system-12345678-vmss000000      Ready    agent   5m    v1.29     10.0.1.4      Ubuntu
aks-system-12345678-vmss000001      Ready    agent   5m    v1.29     10.0.1.5      Ubuntu
```

🧠 **Key observation**:

* `INTERNAL-IP` is from **your VNet subnet**
* Example: `10.0.1.0/24`

---

# 🧪 Validate Pod IPs (This Proves the Lab)

Deploy a test pod:

```bash
kubectl run nginx --image=nginx
```

Check pod IP:

```bash
kubectl get pod nginx -o wide
```

### Example:

```text
NAME    READY   STATUS    IP           NODE
nginx   1/1     Running   10.0.1.10    aks-system-...
```

🎯 **Deliverable achieved**:

> Pods receive VNet IPs

---

## 🔍 Why This Proves Azure CNI

* Pod IP (`10.0.1.10`) is:

  * Same CIDR as node subnet
  * Routable inside Azure VNet
* With **kubenet**, pod IP would be:

  * `10.244.x.x` (overlay network)

---

# 🧠 Azure CNI vs Kubenet (Quick Comparison)

| Feature                    | Azure CNI   | Kubenet |
| -------------------------- | ----------- | ------- |
| Pod IP source              | VNet subnet | Overlay |
| Pod reachable from VNet    | ✅ Yes       | ❌ No    |
| IP consumption             | High        | Low     |
| Enterprise ready           | ✅           | ❌       |
| AKS default (new clusters) | ✅           | ❌       |

---

# 🔥 Common Interview Question (You Can Answer Now)

**Q:** How do pods get IPs in Azure CNI?

**A:**
Azure assigns secondary IPs from the VNet subnet to node NICs, and pods are assigned those IPs directly, making them routable inside the VNet.

---

# ✅ What Changed from Lab 8 → Lab 9?

👉 **Nothing in code**
👉 **Everything in understanding**

Lab 9 is a **validation lab**, not a coding lab.

---

# 🧠 What You Learned

You now:

* Know what Azure CNI is
* Can prove pod IP allocation
* Understand why subnet sizing matters
* Are ready for production AKS networking

---