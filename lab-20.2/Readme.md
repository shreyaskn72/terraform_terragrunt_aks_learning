`terragrunt run-all plan` is **exactly** what teams use once repos grow beyond a single stack.

Below is a **clean, production-ready way** to add **`terragrunt run-all plan`** to your existing GitHub Actions workflow, with a clear explanation of **when and why to use it**.

---

# 🧪 `terragrunt run-all plan` (Multi-stack Planning)

## 🧠 What `run-all plan` Does (Important)

```bash
terragrunt run-all plan
```

It:

* Discovers **all Terragrunt modules** under a directory
* Respects **dependency order**
* Runs `plan` for each stack
* Does **NOT** apply anything

Perfect for:

* CI validation
* Catching breaking changes early
* Multi-env / multi-module repos

---

## 📍 Where It Should Run From

You **must run it from a common parent directory**, usually:

```text
lab-20.2/live
```

This allows Terragrunt to detect:

```
live/
├── dev/aks
├── prod/aks
```

---

# ✅ Add This Job to Your Existing Workflow in 20.1

Below is a **new job** you can add **alongside your current `plan` + `apply` jobs**.

---

## 🔁 `run-all-plan` Job (Copy-Paste Ready)

```yaml
  run-all-plan:
    name: Terragrunt Run-All Plan (All Environments)
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

      - name: Terragrunt Run-All Plan
        working-directory: lab-20.2/live
        run: terragrunt run-all plan
```

---

## 🧠 Why This Job Is Separate

| Job            | Purpose                     |
| -------------- | --------------------------- |
| `plan`         | Fast feedback for one stack |
| `run-all-plan` | Full repo validation        |
| `apply`        | Controlled deployment       |

In real teams:

* PRs → `run-all plan`
* Main branch → env-specific apply

---

## 🛑 VERY IMPORTANT Safety Notes

### ❌ Never do this in CI:

```bash
terragrunt run-all apply
```

Why?

* Applies **everything**
* Dangerous
* Hard to review
* Almost never approved in prod orgs

✅ Always apply **per-environment**, **per-stack**.

---

## 🧪 Typical Execution Flow in Real Orgs

```text
Pull Request:
  ✔ terragrunt run-all plan

Merge to main:
  ✔ terragrunt plan (dev)
  ⏸ manual approval
  ✔ terragrunt apply (dev)
```

---

## ✅ Deliverable Check

✔ `terragrunt run-all plan` added
✔ Plans all stacks safely
✔ Dependencies respected
✔ No infra changes applied

---

## 🔥 Pro Tip (Senior-level)

Add this later for PRs only:

```yaml
if: github.event_name == 'pull_request'
```

So `run-all plan` runs only on PRs, not every push.

---

# 🏁 Complete GitHub Actions Workflow File

Here is the **FULL, FINAL GitHub Actions workflow file** that includes **everything together**:

* ✅ `terragrunt run-all plan` (repo-wide safety check)
* ✅ Per-environment `terragrunt plan`
* ⏸️ Manual approval
* ✅ `terragrunt apply`
* 🔐 Azure auth via GitHub Secrets
* 🧱 Works with your `lab-20.2/live/...` layout

This is **production-grade** and **copy-paste ready**.

---

## 📄 `.github/workflows/terragrunt-aks.yml`

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
  ###################################################################
  # 1️⃣ GLOBAL SAFETY CHECK – RUN-ALL PLAN
  ###################################################################
  run-all-plan:
    name: Terragrunt Run-All Plan (All Environments)
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

      - name: Terragrunt Run-All Plan
        working-directory: lab-20.2/live
        run: terragrunt run-all plan

  ###################################################################
  # 2️⃣ DEV PLAN (FAST, ENV-SPECIFIC)
  ###################################################################
  plan-dev:
    name: Terraform Plan (Dev)
    runs-on: ubuntu-latest
    needs: run-all-plan

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

      - name: Terragrunt Init (Dev)
        working-directory: lab-20.2/live/dev/aks
        run: terragrunt init

      - name: Terragrunt Plan (Dev)
        working-directory: lab-20.2/live/dev/aks
        run: terragrunt plan

  ###################################################################
  # 3️⃣ DEV APPLY (MANUAL APPROVAL)
  ###################################################################
  apply-dev:
    name: Terraform Apply (Dev)
    runs-on: ubuntu-latest
    needs: plan-dev
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

      - name: Terragrunt Init (Dev)
        working-directory: lab-20.2/live/dev/aks
        run: terragrunt init

      - name: Terragrunt Apply (Dev)
        working-directory: lab-20.2/live/dev/aks
        run: terragrunt apply -auto-approve
```

---

## 🔐 REQUIRED GITHUB SETUP (DO THIS ONCE)

### 1️⃣ Secrets

```
Settings → Secrets and variables → Actions
```

Add:

* `ARM_CLIENT_ID`
* `ARM_CLIENT_SECRET`
* `ARM_SUBSCRIPTION_ID`
* `ARM_TENANT_ID`

---

### 2️⃣ Environment (Manual Approval)

```
Settings → Environments → dev
```

Enable:

* ✅ Required reviewers
* Add yourself / team

This is what **pauses the pipeline** before `apply`.

---

## 🧠 EXECUTION FLOW (VERY IMPORTANT)

```text
Pull Request:
  ✔ run-all plan (all stacks)

Merge to main:
  ✔ run-all plan
  ✔ dev plan
  ⏸ manual approval
  ✔ dev apply
```

---

## 🚨 WHY THIS WORKFLOW IS SAFE

| Risk                   | Protection             |
| ---------------------- | ---------------------- |
| Accidental apply       | Manual approval        |
| Hidden breaking change | run-all plan           |
| State corruption       | Remote backend         |
| Env mixups             | Folder-based isolation |
| Secret leaks           | GitHub Secrets         |

This is **exactly how real platform teams run AKS infra**.

---