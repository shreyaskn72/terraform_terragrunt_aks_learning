Below is a **complete, copy-paste-ready solution for Lab 2**, exactly how you’d do it in real projects.

---

# ✅ **Lab 2 – Solution: First Terraform Deployment (Azure)**

## 🎯 Goal

Deploy a **Resource Group** in Azure using Terraform and understand the core Terraform workflow.

---

## 📁 Folder Structure

Inside your repo:

```
terraform-aks-labs/
└── lab-02/
    ├── main.tf
    ├── providers.tf
    └── versions.tf
```

Create the folder and files:

```bash
mkdir lab-02
cd lab-02
```

---

## 1️⃣ `versions.tf`

**Purpose:** Lock Terraform and provider versions (very important in real life)

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

---

## 2️⃣ `providers.tf`

**Purpose:** Configure Azure provider

```hcl
provider "azurerm" {
  features {}
}
```

👉 Authentication is taken automatically from:

* `az login`
* Or environment variables (later labs)

---

## 3️⃣ `main.tf`

**Purpose:** Create Azure Resource Group

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-lab-02"
  location = "East US"
}
```

---

## 4️⃣ Initialize Terraform

```bash
terraform init
```

Expected:

* Provider downloaded
* `.terraform/` folder created

---

## 5️⃣ Review Execution Plan

```bash
terraform plan
```

Expected output:

```
Plan: 1 to add, 0 to change, 0 to destroy
```

---

## 6️⃣ Apply Infrastructure

```bash
terraform apply
```

Type:

```
yes
```

Terraform output:

```
Apply complete! Resources: 1 added.
```

---

## 7️⃣ Verify in Azure

### Option 1: Azure Portal

* Go to **Resource Groups**
* You should see:

  ```
  rg-terraform-lab-02
  ```

### Option 2: Azure CLI

```bash
az group show --name rg-terraform-lab-02
```

---

## 8️⃣ Destroy (Important Habit)

Always clean up labs:

```bash
terraform destroy
```

---

## 📦 Deliverables for Lab 2

You should now have:

* ✔ A working Terraform project
* ✔ Azure Resource Group created
* ✔ Understanding of:

  * Provider
  * Resource
  * Init / Plan / Apply / Destroy

---

## 🧠 What You Learned in Lab 2

* Terraform project structure
* How providers work
* Terraform lifecycle
* How state is created (local state for now)

---

## 🔜 What’s Next

**Lab 3: Azure Authentication**

* Service Principal
* Secure authentication
* No credentials in code
