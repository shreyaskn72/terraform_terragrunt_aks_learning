
Let’s do **Lab 1: IaC & Tooling Setup** properly, step by step, with **commands + validation**, so you can be 100% sure you’re ready before touching AKS.

---

# ✅ **Lab 1 – Solution: IaC & Tooling Setup**

## 🎯 Goal

Prepare your local machine and Azure account for Terraform + Terragrunt development.

---

## 1️⃣ Install Terraform

### 🔹 Windows (recommended way)

Using **Chocolatey** (best for updates):

```powershell
choco install terraform -y
```

Or manual install:

1. Download from Terraform website
2. Extract `terraform.exe`
3. Add folder to **PATH**

### ✅ Verify

```bash
terraform version
```

Expected output (version may differ):

```
Terraform v1.6.x
```

---

## 2️⃣ Install Terragrunt

### 🔹 Windows

Using Chocolatey:

```powershell
choco install terragrunt -y
```

Manual:

* Download `terragrunt_windows_amd64.exe`
* Rename to `terragrunt.exe`
* Add to PATH

### ✅ Verify

```bash
terragrunt --version
```

Expected:

```
terragrunt version v0.5x.x
```

---

## 3️⃣ Install Azure CLI

### 🔹 Windows

```powershell
choco install azure-cli -y
```

### ✅ Verify

```bash
az version
```

---

## 4️⃣ Login to Azure

```bash
az login
```

* Browser opens
* Login with your Azure account

### Set Subscription (VERY important)

```bash
az account list -o table
```

```bash
az account set --subscription "<SUBSCRIPTION_ID>"
```

### ✅ Verify

```bash
az account show -o table
```

---

## 5️⃣ (Optional but Recommended) Install kubectl

```powershell
choco install kubernetes-cli -y
```

### ✅ Verify

```bash
kubectl version --client
```

---

## 6️⃣ Create Project Folder Structure

```bash
mkdir terraform-aks-labs
cd terraform-aks-labs
```

Initialize Git:

```bash
git init
```

Create `.gitignore`:

```bash
terraform.tfstate
terraform.tfstate.backup
.terraform/
*.tfvars
```

---

## 7️⃣ Final Validation Checklist ✅

Run all of these successfully:

```bash
terraform version
terragrunt --version
az account show
kubectl version --client
git status
```

---

## 📦 Deliverables for Lab 1

You should now have:

* ✔ Terraform installed
* ✔ Terragrunt installed
* ✔ Azure CLI logged in
* ✔ Git repo created
* ✔ Clean project directory

---

## 🧠 What You Learned in Lab 1

* Toolchain setup (real-world requirement)
* Azure authentication baseline
* Repo hygiene from day one

---
