Love this pace — you’re building *understanding*, not just infra 👌

Below is **Lab 4 written as a deep-explanation lab**, exactly like Lab 3.

---

# 🧠 **Lab 4 – Variables, Outputs & Locals (Deep Explanation)**

---

## 🎯 What This Lab Is Really About

So far, your Terraform code **works**, but it’s **not reusable**.

Right now:

* Values are hardcoded ❌
* You can’t reuse the same code for dev / stage / prod ❌
* Changing region or name requires editing code ❌

This lab fixes that by introducing:

* **Variables** → external inputs
* **Outputs** → expose useful values
* **Locals** → internal computed values

These three together form the **foundation for Terragrunt** later.

---

## 🧩 Mental Model (Important)

Think of Terraform like a function:

```text
Terraform(inputs) → Infrastructure → outputs
```

* **Variables** = function arguments
* **Locals** = internal variables
* **Outputs** = return values

---

## 📁 Folder Structure

We’ll enhance **Lab 2**, to **Lab 4**.

```
lab-04/
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

---

## 1️⃣ Input Variables (`variables.tf`)

### Why variables exist

Hardcoding:

```hcl
location = "East US"
```

Means:

* ❌ You must edit code for every environment
* ❌ Git history gets noisy
* ❌ CI/CD becomes painful

Variables solve this.

---

### `variables.tf`

```hcl
variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}
```

---

### What’s happening here

| Field         | Meaning                                   |
| ------------- | ----------------------------------------- |
| `variable`    | Declares an input Terraform expects       |
| `description` | Documentation (shows in `terraform plan`) |
| `type`        | Enforces correctness                      |
| `default`     | Optional value if not provided            |

If no default → Terraform **forces you** to supply it.

---

## 2️⃣ Variable Values (`terraform.tfvars`)

### Why `.tfvars` exists

Terraform needs actual values **at runtime**.

You can pass variables via:

* CLI flags ❌ (messy)
* Environment variables ❌ (not scalable)
* `.tfvars` files ✔ (best practice)

---

### `terraform.tfvars`

```hcl
resource_group_name = "rg-terraform-lab-02"
location            = "East US"
environment         = "dev"
```

Terraform automatically loads:

* `terraform.tfvars`
* `*.auto.tfvars`

---

## 3️⃣ Using Variables in Resources (`main.tf`)

### Before (hardcoded)

```hcl
name     = "rg-terraform-lab-02"
location = "East US"
```

---

### After (parameterized)

```hcl
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}
```

---

## 4️⃣ Locals (`locals.tf` concept)

### Why locals exist

Sometimes:

* Variables aren’t enough
* You need **computed values**
* You want consistent naming

Locals are **internal-only** values.

---

### Add to `main.tf` (top section)

```hcl
locals {
  rg_name = "${var.resource_group_name}-${var.environment}"
}
```

---

### What Terraform does with locals

1. Reads variables
2. Computes locals
3. Uses locals in resources

Locals:

* Are evaluated once
* Cannot be overridden
* Improve readability

---

## 5️⃣ Outputs (`outputs.tf`)

### Why outputs matter

Terraform creates resources, but:

* How do other modules use them?
* How does Terragrunt read them?
* How do humans see them?

Outputs solve this.

---

### `outputs.tf`

```hcl
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "The Azure region of the resource group"
  value       = azurerm_resource_group.rg.location
}
```

---

### What happens internally

After `terraform apply`:

* Terraform stores outputs in state
* Outputs are printed to terminal
* Other modules can reference them

Example:

```bash
terraform output resource_group_name
```

---

## 6️⃣ Execution Flow (Very Important)

When you run:

```bash
terraform apply
```

Terraform does this **in order**:

1. Load variable definitions
2. Load variable values (`.tfvars`)
3. Evaluate locals
4. Initialize providers
5. Build dependency graph
6. Generate execution plan
7. Apply changes
8. Save state + outputs

Understanding this order is key to debugging later.

---

## 7️⃣ Run & Validate

```bash
terraform init
terraform plan
terraform apply
```

Expected resource name:

```
rg-terraform-lab-02-dev
```

---

## 📦 What You Achieved in Lab 4

You now have:

* ✔ Environment-agnostic Terraform code
* ✔ Clean separation of inputs, logic, outputs
* ✔ Naming standards
* ✔ Foundation for modules & Terragrunt

---

## 🧠 Key Takeaways (Interview Gold)

* Variables = external inputs
* Locals = internal logic
* Outputs = shared results
* `.tfvars` = environment configuration
* Never hardcode environment-specific values

---

## 🔜 Next Lab (Lab 5 Preview)

**Terraform Remote State**

* Why local state is dangerous
* Azure Blob backend
* State locking
* Team-safe Terraform




You’re now officially past *beginner Terraform* 🚀
