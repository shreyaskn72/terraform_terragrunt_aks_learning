Lab 23 is where you stop writing *“works on my machine Terraform”* and start writing **production-grade infra code**.

I’ll structure this exactly like a **real engineering review**:

👉 identify bad patterns

👉 explain *why they hurt*


👉 show *how to refactor*

👉 end with a clean target architecture

---

# 🚫 Lab 23: Terraform & Terragrunt Anti-Patterns

## 🎯 Goal

Learn to **spot**, **explain**, and **fix** Terraform mistakes that:

* break security
* kill scalability
* slow teams
* cause outages

---

# PART 1️⃣ Anti-Pattern: Hardcoded Secrets

## ❌ What It Looks Like

```hcl
resource "azurerm_kubernetes_cluster" "this" {
  name     = "aks-dev"

  service_principal {
    client_id     = "12345678-abcd-efgh"
    client_secret = "SuperSecretPassword!"
  }
}
```

---

## 🚨 Why This Is Dangerous

| Problem                   | Impact               |
| ------------------------- | -------------------- |
| Secrets in Git            | Permanent compromise |
| PR reviews expose secrets | Leaks                |
| Rotation impossible       | Security debt        |
| State file stores secrets | More leakage         |

💣 **One leaked commit = breach**

---

## ✅ Correct Pattern: Managed Identity + External Secrets

### Step 1: Use Managed Identity

```hcl
identity {
  type = "SystemAssigned"
}
```

✔ No secrets
✔ Azure-managed rotation
✔ Least privilege

---

### Step 2: Use Variables (when secrets unavoidable)

```hcl
variable "admin_password" {
  type      = string
  sensitive = true
}
```

Inject via:

```bash
export TF_VAR_admin_password="secret"
```

or GitHub Actions secrets.

---

### Step 3: Key Vault (Production)

```hcl
data "azurerm_key_vault_secret" "db" {
  name         = "db-password"
  key_vault_id = azurerm_key_vault.this.id
}
```

---

## ✅ Result

* No secrets in repo
* No secrets in logs
* Audit-friendly

---

# PART 2️⃣ Anti-Pattern: Large Root Modules

## ❌ What It Looks Like

```text
main.tf (1200 lines)
├─ VNet
├─ Subnets
├─ AKS
├─ Node pools
├─ Log Analytics
├─ RBAC
├─ DNS
```

---

## 🚨 Why This Hurts

| Issue                            | Effect           |
| -------------------------------- | ---------------- |
| Hard to understand               | Slow onboarding  |
| Small change = huge blast radius | Risk             |
| No reuse                         | Copy-paste infra |
| Conflicts in team                | Merge hell       |

---

## ✅ Correct Pattern: Small, Focused Modules

### Refactor into:

```text
modules/
├── network/
├── aks/
├── monitoring/
├── identity/
```

Each module:

* Has **one responsibility**
* Exposes outputs
* Has minimal inputs

---

### Example: AKS Module

```hcl
module "aks" {
  source              = "../modules/aks"
  cluster_name        = var.cluster_name
  subnet_id           = module.network.subnet_id
  log_analytics_id    = module.monitoring.workspace_id
}
```

---

## ✅ Result

* Clean separation
* Easy testing
* Safe changes

---

# PART 3️⃣ Anti-Pattern: Everything in Terraform Root

## ❌ What It Looks Like

```hcl
provider "azurerm" {}
terraform {
  backend "azurerm" {}
}
resource "azurerm_*" {}
```

Copied across:

* dev
* stage
* prod

---

## 🚨 Why This Breaks Teams

| Problem             | Impact         |
| ------------------- | -------------- |
| Backend duplication | State mistakes |
| Env drift           | Prod incidents |
| Copy-paste errors   | Downtime       |
| No policy control   | Chaos          |

---

## ✅ Correct Pattern: Terragrunt DRY Layer

### Terraform = pure modules

### Terragrunt = orchestration

```hcl
# terragrunt.hcl
terraform {
  source = "../../modules/aks"
}

inputs = {
  cluster_name = "aks-dev"
}
```

Backend handled **once** in parent `terragrunt.hcl`.

---

## ✅ Result

* Zero duplication
* Environment isolation
* Clean Terraform modules

---

# PART 4️⃣ Anti-Pattern: Mixing Environments in One State

## ❌ What It Looks Like

```hcl
resource "azurerm_kubernetes_cluster" "dev" {}
resource "azurerm_kubernetes_cluster" "prod" {}
```

Same state file 😬

---

## 🚨 Why This Is Dangerous

* One apply affects multiple envs
* Impossible rollbacks
* Accidental prod changes

---

## ✅ Correct Pattern: One State per Environment

```text
live/
├── dev/aks
├── stage/aks
├── prod/aks
```

Each folder:

* Separate backend
* Separate state
* Separate lifecycle

---

# PART 5️⃣ Anti-Pattern: Ignoring Outputs & Dependencies

## ❌ What It Looks Like

```hcl
subnet_id = "/subscriptions/xxx/subnets/aks"
```

---

## 🚨 Why This Fails

* Hard to change
* Breaks refactors
* No dependency tracking

---

## ✅ Correct Pattern: Outputs + Terragrunt Dependencies

```hcl
dependency "network" {
  config_path = "../network"
}

inputs = {
  subnet_id = dependency.network.outputs.subnet_id
}
```

Terraform:
✔ Orders correctly
✔ Zero manual wiring

---

# PART 6️⃣ Anti-Pattern: No Naming or Tag Standards

## ❌ What It Looks Like

```hcl
name = "test123"
```

---

## ✅ Correct Pattern: Centralized Naming

```hcl
locals {
  name_prefix = "${var.env}-${var.project}"
}

name = "${local.name_prefix}-aks"
```

Add tags:

```hcl
tags = {
  env     = var.env
  owner   = "platform"
  project = var.project
}
```

---

# PART 7️⃣ Refactored “Good” End State

```text
terraform_terragrunt_aks_learning/
├── modules/
│   ├── network/
│   ├── aks/
│   ├── monitoring/
│   └── identity/
├── live/
│   ├── dev/
│   ├── stage/
│   └── prod/
└── .github/workflows/
```

✔ Secure
✔ Reusable
✔ Scalable
✔ Auditable

---

# ✅ Deliverable Checklist

✔ Hardcoded secrets removed
✔ Modules split correctly
✔ Terragrunt orchestration added
✔ Environment isolation enforced
✔ Clean, maintainable infra code

---

# 🧠 What This Lab Really Teaches

> **Terraform success is about design, not syntax.**

Bad Terraform:

* works once
* breaks later

Good Terraform:

* boring
* predictable
* safe

---
