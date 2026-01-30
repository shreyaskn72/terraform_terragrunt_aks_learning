
---

# 🧠 **Lab 6 – Terraform Modules (Deep Explanation – Root & Module Separation)**

> Folder structure used:
>
> ```
> lab-06/
> ├── root/
> │   ├── main.tf
> │   ├── variables.tf
> │   ├── outputs.tf
> │   ├── providers.tf
> │   └── versions.tf
> │
> └── modules/
>     └── resource-group/
>         ├── main.tf
>         ├── variables.tf
>         └── outputs.tf
> ```

This mirrors **how Terraform is structured in real companies**.

---

## 🎯 What This Lab Is Really About

This lab is **not** about creating a resource group.

It’s about learning **how Terraform composes infrastructure** using:

* A **root module** (orchestrator)
* One or more **child modules** (implementation)

You are learning *architecture*, not syntax.

---

## 🧩 Mental Model (Critical)

Terraform always runs from **one root module**.

```text
terraform apply
   ↓
Root module (root/)
   ↓
Child modules (modules/*)
   ↓
Resources
```

Terraform **never** runs a child module directly.

---

## 1️⃣ Root Module (Your `root/` Folder)

### What is the root module?

The root module is:

* The folder where you run `terraform init / apply`
* The entry point for Terraform
* Responsible for **wiring things together**

In your case:

```
lab-06/root
```

This is why you copied **all Lab 5 files** here.

---

### What belongs in the root module?

✔ Providers
✔ Backend configuration
✔ Variables for environment
✔ Module calls
❌ Actual resource definitions (ideally)

---

## 2️⃣ Child Module (Your `modules/resource-group` Folder)

### What is a module?

A module is:

* A **reusable building block**
* Contains real Azure resources
* Has a clear input/output contract

It does **one job well**.

---

### `modules/resource-group/main.tf`

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
}
```

💡 Notice:

* No provider block
* No backend block
* No environment logic

This keeps modules **pure and reusable**.

---

## 3️⃣ Module Inputs (`modules/resource-group/variables.tf`)

```hcl
variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}
```

### Why modules *must* declare variables

Modules:

* Don’t know where they’re used
* Don’t read root variables
* Must be explicit

This prevents hidden coupling.

---

## 4️⃣ Module Outputs (`modules/resource-group/outputs.tf`)

```hcl
output "name" {
  value = azurerm_resource_group.this.name
}

output "location" {
  value = azurerm_resource_group.this.location
}
```

### Why outputs exist

Outputs are:

* The **only way** data flows *out* of a module
* Used by root or other modules later

Think of outputs as a **public API**.

---

## 5️⃣ Wiring Everything in the Root Module

### `root/main.tf`

```hcl
locals {
  rg_name = "${var.resource_group_name}-${var.environment}"
}

module "resource_group" {
  source   = "../modules/resource-group"
  name     = local.rg_name
  location = var.location
}
```

---

### What’s happening here (Important)

1. Root calculates environment-specific values
2. Root passes only what the module needs
3. Module creates resources
4. Outputs flow back to root

This is **clean separation of concerns**.

---

## 6️⃣ Root Variables (`root/variables.tf`)

```hcl
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}
```

### Why environment stays in root

Modules should:

* Not know about `dev`, `prod`
* Not care about naming conventions

That logic belongs **only in root**.

---

## 7️⃣ Root Outputs (`root/outputs.tf`)

```hcl
output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_location" {
  value = module.resource_group.location
}
```

Root outputs:

* Aggregate module outputs
* Expose values for humans or Terragrunt later

---

## 8️⃣ Execution Flow (This Is Key)

From inside:

```bash
cd lab-06/root
terraform init
terraform plan
terraform apply
```

Terraform does:

1. Treats `root/` as root module
2. Loads backend config (from Lab 5)
3. Loads provider
4. Loads child module from `../modules`
5. Builds dependency graph
6. Applies resources
7. Stores state **with module paths**

---

## 9️⃣ Inspect State (Educational)

```bash
terraform state list
```

You’ll see:

```
module.resource_group.azurerm_resource_group.this
```

This proves:

* Module isolation
* Proper wiring

---

## 🔥 Why This Structure Is Excellent (Real-World)

Your structure allows:

* Multiple roots (`dev`, `prod`, later with Terragrunt)
* Shared modules
* Clean CI/CD pipelines
* Easy refactoring

This is **exactly** how AKS platforms are built.

---

## 📦 What You Achieved in Lab 6

You now have:

* ✔ Clear root vs module separation
* ✔ Reusable modules
* ✔ Environment-specific logic in root
* ✔ Production-grade repo structure

---

## 🧠 Key Interview Insight

> Terraform does not scale by writing more resources
> It scales by composing modules from a clean root

You’re already thinking like a platform engineer 👏

---

## 🔜 Next Lab (Lab 7 Preview)

**Advanced Terraform Language**

* `for_each` vs `count`
* `dynamic` blocks
* Conditional logic
* Dependency management



This repo structure is *solid* — nice work 💪
