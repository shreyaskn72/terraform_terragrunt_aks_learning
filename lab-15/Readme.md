This is a **very important lab** — once this clicks, Terragrunt will finally *make sense* instead of feeling like “Terraform but confusing” 😄
Let’s do this **slowly, cleanly, and with strong mental models**.

---

# 🧠 Lab 15 – Remote State via Terragrunt

**Goal: Centralized state (the right way)**

---

## 🎯 What This Lab Is REALLY About

> **Terraform should not care where state lives.
> Terragrunt should own state completely.**

After this lab:

* Terraform code = **pure infrastructure logic**
* Terragrunt = **state, environment, orchestration**
* No backend blocks in Terraform anymore

🎯 **Deliverable**:

> State fully managed by Terragrunt

---

# 🧠 Why This Matters (Real World)

Without centralized state:

* Team members overwrite each other
* CI/CD breaks
* Rollbacks are risky
* Prod becomes dangerous

**Terragrunt’s killer feature = state management at scale**

---

# 🧩 Starting Point (What You Have Now)

From **Lab 14**, you already have:

```
lab-15/
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

And **remote_state is already defined in Terragrunt**.

Now we **finish the job properly**.

---

# 🧠 Core Rule of Lab 15

> ❌ Terraform must NOT define backend
> ✅ Terragrunt must define backend

---

# 🛑 Step 1: Remove Backend from Terraform (If Any)

### ❌ BAD (Terraform-managed backend)

If you have **anything like this** in Terraform:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaksdemo"
    container_name       = "dev"
    key                  = "aks.tfstate"
  }
}
```

👉 **DELETE IT**

---

### ✅ GOOD (Terraform is backend-agnostic)

Your `versions.tf` should look like this **only**:

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

🧠 Terraform no longer knows or cares about state.

---

# 🧠 Step 2: Centralize State in Terragrunt

Now Terragrunt becomes the **single source of truth**.

---

## 📄 `terragrunt/dev/aks/terragrunt.hcl`

```hcl
terraform {
  source = "../../../terraform/aks"
}
```

🧠 Still pointing to reusable Terraform code.

---

## 🔹 Add Remote State (THE IMPORTANT PART)

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

---

## 🧠 What Terragrunt Does Here (Internals)

When you run `terragrunt init`:

1. Terragrunt **injects a backend block**
2. Terraform never sees it in source code
3. State is stored in Azure Storage
4. Each env gets isolated state

This is **clean, safe, scalable**

---

## 🔹 Inputs (Still Environment-Specific)

```hcl
inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"
}
```

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

# ▶️ Step 3: Initialize with Terragrunt

Navigate to:

```bash
cd terragrunt/dev/aks
```

### Initialize

```bash
terragrunt init
```

🧠 What happens:

* Terragrunt generates a backend config
* Terraform initializes remote state
* `.terragrunt-cache` is created

---

# ▶️ Step 4: Apply

```bash
terragrunt apply
```

🧠 Internally:

* Terraform runs with injected backend
* State stored in Azure Storage
* No local `.tfstate` file

---

# ✅ Step 5: Verify State Location

### Check local directory:

```bash
ls
```

❌ No `terraform.tfstate` file

---

### Check Azure Portal:

* Storage Account → Containers → `dev`
* You should see:

```
aks.tfstate
```

🎯 **Deliverable achieved**:

> State fully managed by Terragrunt

---

# 🧠 Why This Design Is Gold Standard

| Concern          | Terraform | Terragrunt |
| ---------------- | --------- | ---------- |
| Infra logic      | ✅         | ❌          |
| Remote state     | ❌         | ✅          |
| Environment mgmt | ❌         | ✅          |
| DRY              | ⚠️        | ✅          |

---

# 🔥 Interview-Ready Explanation

> “We remove all backend configuration from Terraform and let Terragrunt centrally manage remote state per environment.”

That line alone = **senior-level confidence**.

---

# 🧭 Common Mistakes (Avoid These)

❌ Backend in Terraform + Terragrunt
❌ One state file for all environments
❌ Local state in production
❌ Hardcoding backend values in Terraform

---


