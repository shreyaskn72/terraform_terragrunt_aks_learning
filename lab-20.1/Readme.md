
I’ll show you **the clean, minimal, real-world Terraform + Terragrunt folder layout** that works perfectly with the **Lab-20 GitHub Actions workflow** we just discussed.

I’ll also explain **why each folder exists** and **which path the pipeline should run from**.

---

# ✅ Recommended Folder Structure for Lab-20 (CI/CD-ready)

```
lab-20.1/
├── modules/
│   └── aks/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── live/
│   ├── dev/
│   │   └── aks/
│   │       └── terragrunt.hcl
│   │
│   └── prod/
│       └── aks/
│           └── terragrunt.hcl
│
├── terragrunt.hcl          # root (remote state + provider)
└── README.md
```

This structure is **intentional** and **battle-tested**.

---

## 🧠 Big Picture (Who Does What?)

| Layer                   | Responsibility                      |
| ----------------------- | ----------------------------------- |
| `modules/`              | Terraform **resources** (AKS logic) |
| `live/`                 | Environment **configuration**       |
| `terragrunt.hcl` (root) | Backend, provider, DRY config       |
| GitHub Actions          | Automation + approvals              |

---

## 1️⃣ Terraform Module (`modules/aks/`)

### Purpose

Defines **what AKS looks like**, not *where* it runs.

### Files inside

```
modules/aks/
├── main.tf        # AKS resources
├── variables.tf   # Inputs (node size, cluster name, etc.)
└── outputs.tf     # Exposed values
```

✔ No backend
✔ No providers
✔ No environment logic

This makes the module:

* Reusable
* Testable
* CI-friendly

---

## 2️⃣ Live Environment Config (`live/dev/aks`)

This is the **execution entry point** for CI/CD.

```
live/dev/aks/
└── terragrunt.hcl
```

### Example `terragrunt.hcl`

```hcl
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  cluster_name        = "aks-dev"
  resource_group_name = "rg-aks-dev"
  location            = "eastus"

  system_node_vm_size = "Standard_DS2_v2"
  system_node_count   = 1
}
```

---

## 3️⃣ Root Terragrunt (`lab-20.1/terragrunt.hcl`)

This is **shared configuration**.

```hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatecicdaks"
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

### Why this matters for CI/CD

✔ State stored remotely
✔ Environment isolation
✔ No local state in runners
✔ No provider duplication

---

## 4️⃣ Where GitHub Actions Runs Terraform

### 🔑 **This is the most important part**

Your pipeline **must run from the environment folder**, not the repo root.

✅ Correct:

```
lab-20.1/live/dev/aks
```

❌ Wrong:

```
lab-20.1/
modules/aks/
```

---

Below is a **complete, production-grade GitHub Actions workflow** for **Lab 20.1**, designed specifically for **Terraform + Terragrunt**, with:

* ✅ Automatic `plan`
* ⏸️ Manual approval for `apply`
* 🔐 Azure authentication via secrets
* 🧱 Clean separation of plan vs apply
* 🧠 Works with your `live/dev/aks` structure

This is **copy-paste ready**.

---

# 📄 `.github/workflows/terragrunt-aks.yml`

```yaml
name: Terragrunt AKS CI/CD

on:
  push:
    branches:
      - main
  pull_request:

env:
  ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}

jobs:
  plan:
    name: Terraform Plan (Dev)
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.6

      - name: Install Terragrunt
        run: |
          curl -Lo terragrunt https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64
          chmod +x terragrunt
          sudo mv terragrunt /usr/local/bin/

      - name: Terragrunt Init
        working-directory: lab-20.1/live/dev/aks
        run: terragrunt init

      - name: Terragrunt Plan
        working-directory: lab-20.1/live/dev/aks
        run: terragrunt plan
```

---

## ⏸️ Manual Approval + Apply Job

```yaml
  apply:
    name: Terraform Apply (Dev)
    runs-on: ubuntu-latest
    needs: plan
    environment: dev

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Install Terragrunt
        run: |
          curl -Lo terragrunt https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64
          chmod +x terragrunt
          sudo mv terragrunt /usr/local/bin/

      - name: Terragrunt Init
        working-directory: lab-20.1/live/dev/aks
        run: terragrunt init

      - name: Terragrunt Apply
        working-directory: lab-20.1/live/dev/aks
        run: terragrunt apply -auto-approve
```

---

# 🔐 REQUIRED: GitHub Environment Setup (DO NOT SKIP)

Go to:

```
GitHub Repo → Settings → Environments → dev
```

Enable:

* ✅ **Required reviewers**
* Add yourself (or team)

👉 This is what enforces **manual approval** before `apply`.

---

## 🧠 What This Workflow Does (Very Clearly)

### Job 1: `plan`

* Runs on PRs and pushes
* Shows infrastructure diff
* Safe, automatic
* No changes applied

### Job 2: `apply`

* Runs **only after plan succeeds**
* Pauses for manual approval
* Applies infra changes

This matches **real enterprise change control**.

---

## 📍 Where Terraform Actually Runs

```text
lab-20.1/live/dev/aks
```

That folder:

* Includes root `terragrunt.hcl`
* Uses remote state
* Pulls AKS module
* Is CI-safe

---

## ✅ Deliverable Check

✔ GitHub Actions workflow exists
✔ `terragrunt plan` automated
✔ `terragrunt apply` gated by approval
✔ AKS deployed via CI/CD

---
