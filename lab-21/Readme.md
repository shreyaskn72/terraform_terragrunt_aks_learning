This is an **excellent capstone lab**.



Lab 21 is where you stop *building AKS* and start **operating AKS like an SRE / Platform Engineer**.

I’ll explain:

* **What changes**
* **What commands you run**
* **What AKS is doing internally**
* **How zero-downtime is achieved**
* **How Terraform/Terragrunt fits into Day-2 ops**

No fluff, real-world behavior.

---

# 🧪 Lab 21: Day-2 Operations (AKS)

## 🎯 Goal

Operate AKS **safely after it is live**, including:

* Kubernetes upgrades
* Node pool scaling
* Failure simulation & recovery

👉 All **without downtime**.

---

## 🧠 Day-2 Operations Mindset

| Day-1           | Day-2              |
| --------------- | ------------------ |
| Create cluster  | Keep it healthy    |
| Terraform apply | Controlled changes |
| Happy path      | Failure handling   |
| One-time        | Continuous         |

AKS is **never static** in real orgs.

---

# PART 1️⃣ Upgrade Kubernetes Version (Zero Downtime)

---

## 🔍 Step 1: Check Available Versions

```bash
az aks get-upgrades \
  --resource-group rg-aks-prod \
  --name aks-prod \
  -o table
```

AKS:

* Shows **control plane** versions
* Shows **node pool** upgrade paths
* Enforces **safe version skew**

👉 You **cannot jump versions arbitrarily**.

---

## 🛠 Step 2: Upgrade Using Terraform (Correct Way)

### Update AKS module input

In your **Terraform AKS module**:

```hcl
variable "kubernetes_version" {
  type = string
}
```

In `main.tf`:

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  kubernetes_version = var.kubernetes_version
}
```

---

### Update Terragrunt (Day-2 change)

`live/prod/aks/terragrunt.hcl`

```hcl
inputs = {
  kubernetes_version = "1.29.3"
}
```

---

### Apply via CI/CD or locally

```bash
terragrunt plan
terragrunt apply
```

---

## 🔄 What AKS Does Internally

1. Upgrades **control plane first**
2. Creates **new nodes**
3. Drains old nodes:

   * Pods evicted gracefully
   * Respect `PodDisruptionBudget`
4. Deletes old nodes

👉 **No downtime if pods are replicated**.

---

## ✅ Zero-Downtime Requirements (Very Important)

To truly have zero downtime, workloads must have:

```yaml
replicas: 2
```

and optionally:

```yaml
podDisruptionBudget:
  minAvailable: 1
```

---

# PART 2️⃣ Scale Node Pools (Live Traffic)

---

## 🔍 Horizontal Scaling (Node Count)

### Terraform change

```hcl
variable "system_node_count" {
  type = number
}
```

Change input:

```hcl
system_node_count = 5
```

Apply:

```bash
terragrunt apply
```

---

## 🔄 What Happens

* New nodes join cluster
* Scheduler places pods on new nodes
* No pod restarts required

✔ **Zero downtime**

---

## 🔍 Autoscaling (Already Enabled)

If using autoscaling:

```hcl
enable_auto_scaling = true
min_count = 3
max_count = 10
```

AKS:

* Scales automatically
* Based on pending pods
* No Terraform changes needed for runtime scaling

---

# PART 3️⃣ Simulate Failure & Recover

This is **the most important Day-2 skill**.

---

## 🔥 Scenario 1: Kill a Node (Safe Failure)

```bash
kubectl get nodes
```

Pick one node and simulate failure:

```bash
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets
```

---

## 🔄 What Happens

* Node marked unschedulable
* Pods evicted
* Scheduler reschedules pods on healthy nodes
* Traffic continues

✔ This proves **resilience**

---

## 🔥 Scenario 2: Node Crashes (AKS Auto-Healing)

AKS detects:

* VM unreachable
* Heartbeat lost

AKS:

1. Deletes unhealthy node
2. Creates a new node
3. Rebalances workloads

You don’t touch Terraform at all.

---

## 🔍 Validate Recovery

```bash
kubectl get nodes
kubectl get pods -o wide
```

Pods should be:

* Running
* On different nodes
* No service interruption

---

# PART 4️⃣ Terraform’s Role in Day-2 Ops

This is **critical understanding**:

| Action                    | Terraform? |
| ------------------------- | ---------- |
| Upgrade Kubernetes        | ✅ Yes      |
| Change node size          | ✅ Yes      |
| Change autoscaling bounds | ✅ Yes      |
| Pod rescheduling          | ❌ No       |
| Node auto-healing         | ❌ No       |
| HPA scaling               | ❌ No       |

👉 Terraform **defines desired state**,
👉 Kubernetes **handles runtime behavior**.

---

# PART 5️⃣ Day-2 Best Practices (Real World)

### 🔐 Use Maintenance Windows

AKS supports maintenance windows to avoid business hours.

### 🧾 Always Use `plan`

Never upgrade blindly.

### 🧪 Test in Dev First

Same pipeline, smaller blast radius.

### 📊 Monitor During Ops

Watch:

* Pod restarts
* Node readiness
* API latency

---

# ✅ Deliverable Check

✔ Kubernetes upgraded safely
✔ Node pools scaled live
✔ Failure simulated
✔ AKS recovered automatically
✔ No downtime observed

You are now **operating AKS**, not just deploying it.

---

## 🧠 Why This Lab Is Senior-Level

You now understand:

* Control plane vs node pool upgrades
* How AKS drains nodes
* Why replicas matter
* When Terraform should and shouldn’t be used
* How resilience is *designed*, not hoped for

This is **real production knowledge**.

---

