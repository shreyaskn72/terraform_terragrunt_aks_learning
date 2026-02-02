**Lab 14 is the mental shift from “Terraform user” to “Infrastructure engineer”** 😄
This lab is not about *new resources* — it’s about **how professionals structure infra at scale**.

I’ll explain this **slowly and clearly**, because Terragrunt confusion early on is very common.

---

# 🧠 Lab 14 – Terragrunt Basics (DRY Terraform)

## 🎯 Goal (Plain English)

> Keep **Terraform code reusable**, but move **environment-specific logic** to Terragrunt.

**Outcome**:

* Same AKS infra
* Less duplicated Terraform
* Cleaner structure
* Ready for multi-env (dev / stage / prod)

---

# 🧠 Key Idea Before We Start (VERY IMPORTANT)

### Terraform vs Terragrunt (Think Like This)

| Terraform                 | Terragrunt                        |
| ------------------------- | --------------------------------- |
| Defines **WHAT** to build | Defines **HOW & WHERE** to deploy |
| Resources, modules        | Inputs, backend, environment      |
| Reusable logic            | Glue code                         |

Terragrunt **does NOT replace Terraform**
Terragrunt **wraps Terraform**

---

# 📦 What We Are Converting

You already have **Lab 13 Terraform code** that works.

We will:

* Keep Terraform code **unchanged**
* Move execution logic to Terragrunt

---

# 📁 Final Folder Structure (Industry Standard)

```
lab-14/
├── terraform/
│   └── aks/
│       ├── main.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── outputs.tf
│       └── versions.tf
│
└── terragrunt/
    └── dev/
        └── aks/
            └── terragrunt.hcl
```

🧠 **Why this structure?**

* `terraform/` → reusable code
* `terragrunt/` → environment-specific config

---

# 🧱 Step 1: Terraform Code (UNCHANGED)

Copy your **Lab 13 Terraform files** into:

```
lab-14/terraform/aks/
```

👉 **Do not modify them**
That’s the whole point of Terragrunt.

---

# 🧠 Step 2: Create Terragrunt Configuration

Now we create the **brain** of this lab.

---

## 📄 `lab-14/terragrunt/dev/aks/terragrunt.hcl`

```hcl
terraform {
  source = "../../../terraform/aks"
}
```

### 🧠 What this does

* Tells Terragrunt:

  > “Use Terraform code from this folder”
* Terragrunt copies this code to a temp folder
* Then runs `terraform init / apply` there

This alone already works — but let’s make it powerful.

---

## 🔹 Add Inputs (Environment-Specific)

```hcl
inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"
}
```

🧠 **Key Insight**

* Terraform variables stay generic
* Terragrunt injects real values
* Different envs = different inputs

---

## 🔹 Add Remote State (Big Win)

```hcl
remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaksdemo"
    container_name       = "dev"
    key                  = "aks.tfstate"
  }
}
```

### 🧠 Why this matters

Without this:

* State file lives locally
* No team collaboration
* Risky

With this:

* Central state
* Environment isolated
* Production-safe

---

## ✅ Final `terragrunt.hcl` (Full)

```hcl
terraform {
  source = "../../../terraform/aks"
}

inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"
}

remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaksdemo"
    container_name       = "dev"
    key                  = "aks.tfstate"
  }
}
```

---

# ▶️ Step 3: Run Terragrunt

Go to:

```bash
cd lab-14/terragrunt/dev/aks
```

### Initialize

```bash
terragrunt init
```

🧠 What happens:

* Terraform code is copied to `.terragrunt-cache`
* Backend configured automatically
* Providers downloaded

---

### Apply

```bash
terragrunt apply
```

🧠 What happens internally:

1. Terragrunt injects variables
2. Configures remote backend
3. Calls `terraform apply`
4. Uses shared Terraform code

---

# ✅ Validate Deliverable

```bash
kubectl get nodes
```

Same cluster
Same node pools
Same behavior

🎯 **Deliverable achieved**:

> Same infra, less code

---

# 🧠 Why This Is Powerful (Real-World)

Now adding environments is trivial.

```
terragrunt/
├── dev/
│   └── aks/
│       └── terragrunt.hcl
├── stage/
│   └── aks/
│       └── terragrunt.hcl
└── prod/
    └── aks/
        └── terragrunt.hcl
```

Only inputs change — **Terraform stays untouched**

---

# 🔥 Interview-Level Explanation

> “We keep Terraform modules generic and use Terragrunt to manage environments, remote state, and DRY configuration.”

That’s **senior DevOps language**.

---

# 🧭 Common Beginner Confusions (Cleared)

❌ “Terragrunt replaces Terraform”
✅ No — it orchestrates it

❌ “I need to rewrite Terraform”
✅ No — reuse as-is

❌ “State must be in Terraform”
✅ Terragrunt manages it better

---
# 🎉 Congrats! You Did It!