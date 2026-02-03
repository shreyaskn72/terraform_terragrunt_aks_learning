This lab is where **Terragrunt finally “clicks”** 🔥
Once you understand this, you’ll never want to manage multi-env Terraform *without* Terragrunt again.

I’ll walk you through:

* The **why**
* The **folder layout**
* The **exact files**
* What Terragrunt actually does under the hood

Slow, clear, production-grade explanation 👌

---

# 🧠 Lab 16 – Terragrunt Folder Structure

**Goal: Multi-environment layout with isolation**

---

## 🎯 What This Lab Is REALLY About

> **Same Terraform code
> Different environments
> Different state
> Zero duplication**

🎯 **Deliverable**:
👉 **Environment isolation** (dev, stage, prod)

---

# 🧠 Mental Model (Very Important)

Think in **layers**:

```
Terraform  → reusable logic (modules)
Terragrunt → environments & orchestration
```

* Terraform never knows about dev/stage/prod
* Terragrunt *decides* where and how to deploy

---

# 📁 Final Folder Structure (Industry Standard)

```
lab-16/
├── modules/
│   └── aks/
│       ├── main.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── outputs.tf
│       └── versions.tf
│
└── live/
    ├── terragrunt.hcl        # root config (shared)
    │
    ├── dev/
    │   └── aks/
    │       └── terragrunt.hcl
    │
    ├── stage/
    │   └── aks/
    │       └── terragrunt.hcl
    │
    └── prod/
        └── aks/
            └── terragrunt.hcl
```

🧠 **Why this layout works**

* `modules/` = reusable Terraform
* `live/` = real deployed environments
* Each env has its **own state**
* Same module reused everywhere

---

# 🧱 Step 1: Terraform Module (UNCHANGED)

Your AKS Terraform code (from Lab 13) goes into:

```
modules/aks/
```

👉 No backend
👉 No environment logic
👉 Pure Terraform

---

# 🧠 Step 2: Root Terragrunt Config (Magic File)

This is the **DRY engine**.

---

## 📄 `live/terragrunt.hcl`

```hcl
remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "tfstateaksdemo"
    container_name       = "tg-state"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
```

---

## 🧠 What This File Does

* Applied to **all environments**
* Centralizes backend config
* Generates unique state paths automatically

### 🔑 Key Line Explained

```hcl
key = "${path_relative_to_include()}/terraform.tfstate"
```

| Env   | State Path                  |
| ----- | --------------------------- |
| dev   | dev/aks/terraform.tfstate   |
| stage | stage/aks/terraform.tfstate |
| prod  | prod/aks/terraform.tfstate  |

🎯 **Automatic isolation achieved**

---

# 🧠 Step 3: Environment-Level Terragrunt Configs

Now each environment becomes **tiny and clean**.

---

## 📄 `live/dev/aks/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"
}
```

---

## 📄 `live/stage/aks/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  resource_group_name = "rg-stage-aks"
  location            = "East US"
  cluster_name        = "aks-stage"
}
```

---

## 📄 `live/prod/aks/terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  resource_group_name = "rg-prod-aks"
  location            = "East US"
  cluster_name        = "aks-prod"
}
```

---

# 🧠 What `include` REALLY Does

```hcl
include {
  path = find_in_parent_folders()
}
```

Terragrunt:

1. Searches upward for `terragrunt.hcl`
2. Finds `live/terragrunt.hcl`
3. Merges configs
4. Child overrides parent if needed

🧠 Think:

> **Inheritance for infrastructure**

---

# ▶️ Step 4: Deploy Environments

### Deploy DEV

```bash
cd live/dev/aks
terragrunt apply
```

---

### Deploy STAGE

```bash
cd live/stage/aks
terragrunt apply
```

---

### Deploy PROD

```bash
cd live/prod/aks
terragrunt apply
```

---

# ✅ Verify State Isolation

Check Azure Storage container:

```
tg-state/
├── dev/aks/terraform.tfstate
├── stage/aks/terraform.tfstate
└── prod/aks/terraform.tfstate
```

🎯 **Deliverable achieved**:

> Environment isolation

---

# 🧠 Why This Is the Gold Standard

| Problem              | Solved? |
| -------------------- | ------- |
| Env collision        | ❌ → ✅   |
| Copy-paste Terraform | ❌ → ✅   |
| Safe prod deploys    | ❌ → ✅   |
| DRY infra            | ❌ → ✅   |

---

# 🔥 Interview-Level Explanation

> “We use a live folder with Terragrunt includes to isolate environments while reusing the same Terraform modules.”

That sentence = **senior DevOps energy** 😄

---

# 🧭 Common Beginner Mistakes

❌ Separate Terraform copies per env
❌ Backend defined in Terraform
❌ Same state key for all envs
❌ No root terragrunt.hcl

---
# 🎉 Congrats! You Made It!
