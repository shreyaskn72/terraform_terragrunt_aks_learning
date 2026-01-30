# 🧠 **Lab 3 – Azure Authentication (Deep Explanation Version)**

---

## 🎯 What This Lab Is Really About

Terraform itself **cannot log in to Azure**.

Instead:

* Terraform asks the **Azure provider**
* The Azure provider authenticates using **Azure Active Directory (Entra ID)**
* A **Service Principal** acts like a *non-human user* for automation

This lab creates that non-human identity and teaches Terraform how to use it **securely**.

---

## 1️⃣ Creating a Service Principal (What & Why)

### 🔹 Command

```bash
az ad sp create-for-rbac \
  --name terraform-aks-sp \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>
```

---

### 🔍 What is a Service Principal?

A **Service Principal (SP)** is:

* An identity in Azure AD (Entra ID)
* Used by applications, scripts, CI/CD pipelines
* Governed by **RBAC permissions**

Think of it as:

> “A robot account that Terraform uses to talk to Azure”

---

### 🔎 What each flag means

| Flag                 | Meaning                                                |
| -------------------- | ------------------------------------------------------ |
| `az ad sp`           | You are creating an Azure AD application identity      |
| `create-for-rbac`    | Also assigns permissions automatically                 |
| `--name`             | Friendly name shown in Azure AD                        |
| `--role Contributor` | What this identity is allowed to do                    |
| `--scopes`           | Where the permission applies (subscription-level here) |

---

### 🔐 Why **Contributor** role?

* ✔ Can create, update, delete resources
* ❌ Cannot manage RBAC or subscriptions
* Follows **least privilege principle**

Owner ❌ is dangerous and unnecessary.

---

## 2️⃣ Understanding the Output (Critical)

### Sample Output

```json
{
  "appId": "1111-aaaa",
  "password": "secret",
  "tenant": "2222-bbbb"
}
```

---

### What these values actually are

| Field           | What it represents                   |
| --------------- | ------------------------------------ |
| `appId`         | Client ID (username for the app)     |
| `password`      | Client Secret (password)             |
| `tenant`        | Azure AD tenant ID                   |
| Subscription ID | Which subscription the SP can access |

⚠️ **Azure only shows the secret once**
If you lose it → you must create a new one.

---

## 3️⃣ Why Environment Variables Are Used

Terraform automatically looks for **specific environment variables** when authenticating to Azure.

### Why not put credentials in `.tf` files?

* `.tf` files go to Git
* Secrets leak ❌
* CI/CD pipelines can’t safely read `.tf` secrets

Environment variables solve all of this.

---

## 4️⃣ Setting Environment Variables (What Happens Internally)

### PowerShell

```powershell
$env:ARM_CLIENT_ID="appId"
$env:ARM_CLIENT_SECRET="password"
$env:ARM_SUBSCRIPTION_ID="subscription-id"
$env:ARM_TENANT_ID="tenant-id"
```

---

### What Terraform does with these

When Terraform starts:

1. It loads the Azure provider
2. The provider checks:

   ```
   ARM_CLIENT_ID
   ARM_CLIENT_SECRET
   ARM_TENANT_ID
   ARM_SUBSCRIPTION_ID
   ```
3. It exchanges these with Azure AD
4. Azure AD issues an **OAuth access token**
5. Terraform uses that token to call Azure APIs

👉 Terraform never stores your password.

---

## 5️⃣ Why `providers.tf` Has No Credentials

### `providers.tf`

```hcl
provider "azurerm" {
  features {}
}
```

---

### What happens during `terraform init`

* Terraform downloads the Azure provider
* The provider auto-detects credentials from:

  1. Environment variables ✔
  2. Managed Identity
  3. Azure CLI (fallback)

This keeps code:

* Portable
* Secure
* CI/CD friendly

---

## 6️⃣ Validating Authentication (What You’re Testing)

```bash
terraform plan
```

---

### What Terraform is actually doing

1. Reads configuration files
2. Loads provider
3. Authenticates to Azure AD
4. Queries Azure Resource Manager (ARM)
5. Builds execution plan

If authentication fails → plan fails.

So **successful plan = auth success**.

---

## 7️⃣ Why We Avoid `az login` for Terraform

| Method            | Suitable?                 |
| ----------------- | ------------------------- |
| `az login`        | ❌ Local-only, interactive |
| Service Principal | ✔ Automation, CI/CD       |
| Managed Identity  | ✔ Azure-native            |
| Hardcoded secrets | ❌ Never                   |

---

## 8️⃣ Security Best Practice: `.env` File Pattern

### `.env`

```env
ARM_CLIENT_ID=xxxx
ARM_CLIENT_SECRET=xxxx
ARM_SUBSCRIPTION_ID=xxxx
ARM_TENANT_ID=xxxx
```

### Why this pattern works

* Local-only
* Git ignored
* Easy to rotate secrets
* Mirrors CI/CD variable groups

---

## 📦 What You Have Achieved in Lab 3

You now understand:

* How Terraform authenticates to Azure
* What a Service Principal really is
* How RBAC controls Terraform access
* Why environment variables are critical
* How CI/CD pipelines authenticate

This is **exactly how real production environments work**.

---

## 🔜 Next Lab (Lab 4 Preview)

**Variables, Outputs & Locals**

* Remove hardcoded values
* Support multiple environments
* Prepare for Terragrunt


