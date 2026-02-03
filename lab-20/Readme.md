Awesome — **Lab 20 is where everything clicks** 🔥
You now move from *infrastructure code* → *automated infrastructure delivery*, which is exactly how real platform teams work.

I’ll give you:

1. **Clear architecture explanation**
2. **Exact GitHub Actions workflow**
3. **How manual approval works**
4. **How this integrates with Terraform + Terragrunt**
5. **Validation checklist**

No magic, no hand-waving.

---

# 🧪 Lab 20: CI/CD Integration (Terraform + GitHub Actions)

## 🎯 Goal

Automate infrastructure deployment using **GitHub Actions**:

* `terraform plan` runs automatically
* `terraform apply` requires **manual approval**
* Infra changes are visible, reviewable, and controlled

---

## 🧠 Big Picture (How CI/CD Fits In)

```text
Developer → Git Push → GitHub Actions
                         |
                         ├─ terraform init
                         ├─ terraform plan  (auto)
                         └─ terraform apply (manual approval)
```

Key principle:

> **Humans approve, machines execute**

---

## 📁 Repo Structure (Add This)

```
.github/
└── workflows/
    └── terraform.yml
```

Nothing else needs to change in your Terraform/Terragrunt code.

---

## 1️⃣ GitHub Secrets (Very Important)

Before writing the pipeline, add these secrets in **GitHub repo → Settings → Secrets → Actions**:

| Secret Name           | Value                         |
| --------------------- | ----------------------------- |
| `ARM_CLIENT_ID`       | Azure service principal appId |
| `ARM_CLIENT_SECRET`   | SP password                   |
| `ARM_SUBSCRIPTION_ID` | Azure subscription            |
| `ARM_TENANT_ID`       | Azure tenant                  |

👉 This is **mandatory** for Azure authentication.

---

## 2️⃣ GitHub Actions Workflow

### `.github/workflows/terraform.yml`

```yaml
name: Terraform CI/CD

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
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.6

      - name: Terraform Init
        working-directory: lab-20/live/dev/aks
        run: terraform init

      - name: Terraform Plan
        working-directory: lab-20/live/dev/aks
        run: terraform plan
```

---

## 🔍 What This Pipeline Does (Line by Line)

### `on: push / pull_request`

* Pipeline runs:

  * On every PR
  * On merge to `main`

This gives **early feedback**.

---

### Azure auth via environment variables

Terraform Azure provider automatically reads:

```text
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```

✔ No `az login` required
✔ Works in headless CI

---

### `terraform init`

* Downloads providers
* Configures backend
* Prepares execution environment

---

### `terraform plan`

* Shows **exact infrastructure diff**
* Safe to run automatically
* No resources created yet

---

## 3️⃣ Manual Approval for `terraform apply`

Now we add **a second job with approval gating**.

### Update workflow (Add this job)

```yaml
  terraform-apply:
    runs-on: ubuntu-latest
    needs: terraform
    environment: production

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        working-directory: lab-20/live/dev/aks
        run: terraform init

      - name: Terraform Apply
        working-directory: lab-20/live/dev/aks
        run: terraform apply -auto-approve
```

---

## 4️⃣ Enable Manual Approval (Critical Step)

Go to:

```
GitHub Repo → Settings → Environments → production
```

Enable:

* ✅ **Required reviewers**

Add yourself (or team).

---

### 🔐 What Happens Now

1. `terraform plan` runs automatically
2. GitHub **pauses** the pipeline
3. You see: **“Waiting for approval”**
4. You click **Approve**
5. `terraform apply` runs

This is **enterprise-grade control**.

---

## 5️⃣ Validation (Deliverable Check)

### Check GitHub Actions

* ✅ Plan runs on push
* ⏸ Apply waits for approval
* ✅ Apply runs only after approval

---

### Check Azure

```bash
az aks list -o table
```

Cluster exists / updated → pipeline worked 🎉

---

## 🧠 Why This Is the Right Design

| Problem                  | Solution            |
| ------------------------ | ------------------- |
| Accidental infra changes | Manual approval     |
| No audit trail           | GitHub Actions logs |
| Drift                    | Terraform plan      |
| Secrets in code          | GitHub Secrets      |
| Human error              | Automation          |

This is **how platform teams operate**.

---

## 🚀 Bonus (Optional, but Real-World)

Later improvements:

* Use **Terragrunt instead of Terraform** in pipeline
* Add `terraform fmt -check`
* Add `terraform validate`
* Per-environment pipelines
* PR comments with plan output

---

## ✅ Final Deliverable

✔ CI/CD pipeline created

✔ Terraform plan automated

✔ Terraform apply manually approved

✔ Infra safely deployed

You’ve now completed **end-to-end AKS platform automation** — from zero → production-grade.

