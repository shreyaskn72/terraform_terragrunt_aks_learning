**Lab 22 is where you stop being “scared of Terraform state” and start controlling it.**
This is *exactly* what senior engineers are expected to know.

I’ll walk you through this **step-by-step**, **safely**, with **intentional breakage**, **why it breaks**, and **how to recover without nuking infra**.

---

# 🧪 Lab 22: Failure Scenarios – Terraform State Debugging

## 🎯 Goal

Gain confidence in **fixing Terraform state issues** without:

* deleting real infrastructure
* re-creating AKS
* panicking 😅

---

## 🧠 What Terraform State Really Is

Terraform state:

* Maps **Terraform resource addresses** ➜ **Real cloud resources**
* Is **NOT** the infrastructure itself
* Is a **source of truth** for Terraform only

If state breaks:

* Infra still exists
* Terraform just *loses track of it*

👉 That’s why **state surgery** exists.

---

## ⚠️ Safety Rules Before You Start

✅ Do this in **dev** environment
❌ Never test state surgery first in prod
✅ Always take backup

```bash
terraform state pull > state-backup.json
```

(With Terragrunt)

```bash
terragrunt state pull > state-backup.json
```

---

# PART 1️⃣ Intentionally Break the State (Safe Way)

We will **remove a resource from state**, but **NOT from Azure**.

### Example resource

AKS node pool:

```hcl
azurerm_kubernetes_cluster_node_pool.user
```

---

### 🔥 Break the state

```bash
terragrunt state rm azurerm_kubernetes_cluster_node_pool.user
```

💥 Result:

* Node pool still exists in Azure
* Terraform *thinks it doesn’t*

---

### Verify breakage

```bash
terragrunt plan
```

You’ll see:

```
+ create azurerm_kubernetes_cluster_node_pool.user
```

Terraform wants to **recreate** it → 🚨 danger in prod.

---

## ✅ Congratulations — you broke state successfully

This **exact scenario happens in real companies**.

---

# PART 2️⃣ Investigate State (Read-Only)

---

## 🔍 List what Terraform thinks exists

```bash
terragrunt state list
```

You’ll notice:

* Node pool resource missing
* Everything else intact

---

## 🔍 Inspect real infra (Azure side)

```bash
az aks nodepool list \
  --cluster-name aks-dev \
  --resource-group rg-dev \
  -o table
```

Node pool is clearly **still there**.

👉 **State drift confirmed**

---

# PART 3️⃣ Fix the Problem (Two Real Paths)

---

## 🛠 OPTION 1: Re-import the Resource (Best Practice)

### Find resource ID

```bash
az aks nodepool show \
  --resource-group rg-dev \
  --cluster-name aks-dev \
  --name userpool \
  --query id -o tsv
```

---

### Import back into state

```bash
terragrunt import \
  azurerm_kubernetes_cluster_node_pool.user \
  /subscriptions/.../nodePools/userpool
```

---

### Verify

```bash
terragrunt plan
```

Output:

```
No changes.
```

✅ State restored
✅ Infra untouched
✅ Confidence gained

---

## 🛠 OPTION 2: Remove + Let Terraform Recreate (Destructive)

⚠️ Only acceptable if:

* resource is disposable
* or environment is dev/test

```bash
terragrunt apply
```

Terraform:

* Deletes node pool
* Recreates it

🚫 **Not recommended for prod AKS node pools**

---

# PART 4️⃣ When to Use `terraform state rm`

| Scenario                      | Correct Action    |
| ----------------------------- | ----------------- |
| Resource deleted manually     | `state rm`        |
| Terraform address renamed     | `state mv`        |
| Resource exists but unmanaged | `import`          |
| Drift detected                | Investigate first |

---

# PART 5️⃣ Common Real-World State Failures

### ❌ Manual Azure Portal Change

Terraform doesn’t know → drift

### ❌ Module refactor

Resource address changed

### ❌ Remote state corruption

Bad migration / backend issue

### ❌ Copy-paste environments

Same resource IDs, wrong state

---

# PART 6️⃣ Advanced State Commands (You Should Know)

### Move resource after refactor

```bash
terraform state mv \
  module.old_aks.azurerm_kubernetes_cluster.this \
  module.new_aks.azurerm_kubernetes_cluster.this
```

---

### Show raw state entry

```bash
terraform state show azurerm_kubernetes_cluster.this
```

---

### Replace resource without touching others

```bash
terraform apply -replace="azurerm_kubernetes_cluster_node_pool.user"
```

---

# PART 7️⃣ Terragrunt + State Debugging (Important)

Terragrunt:

* Does **not change Terraform state behavior**
* Only **wraps** Terraform

All these work:

```bash
terragrunt state list
terragrunt state rm
terragrunt import
```

---

# ✅ Deliverable Check

✔ State intentionally broken
✔ Drift identified
✔ `state list` used
✔ `state rm` understood
✔ State repaired safely

You now **control Terraform**, not the other way around.

---

# 🧠 What This Lab Really Teaches

* Terraform state is **recoverable**
* Panic deletes infra — knowledge saves it
* Senior engineers **inspect first, act second**
* State surgery is a **skill**, not a hack

---

