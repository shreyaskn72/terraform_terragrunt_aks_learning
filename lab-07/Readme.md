Let’s go — **Lab 7 is where Terraform starts to feel like a real programming language** 🧠
This lab explains the *why* behind each construct, not just the syntax.

Let's stick to **folder model** (`lab-07/root` + `lab-07/modules`) and show **exactly where things live**.

---

# 🧠 **Lab 7 – Advanced Terraform Language (Deep Explanation)**

---

## 🎯 What This Lab Is Really About

So far, your Terraform is:

* Static
* Predictable
* One-resource-at-a-time

Real infrastructure is:

* Repetitive
* Conditional
* Environment-aware

Terraform’s **expression language** lets you:

* Create multiple resources dynamically
* Avoid copy-paste
* Control dependencies explicitly

---

## 🧩 Mental Model (Critical)

Terraform is **declarative**, but:

* The *graph* is built using expressions
* Expressions decide *what exists*

You are not writing loops —
you are **describing a graph**.

---

## 📁 Folder Structure Used

```
lab-07/
├── root/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── versions.tf
│
└── modules/
    └── network/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

We’ll build a **network module** to demonstrate all advanced concepts.

---

## 1️⃣ `for_each` vs `count` (Most Important Choice)

### ❌ `count` (Index-based)

```hcl
count = 3
```

Problems:

* Index-based
* Reordering causes recreation
* Hard to reference

---

### ✅ `for_each` (Key-based)

#### Root variable (`root/variables.tf`)

```hcl
variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}
```

Example value:

```hcl
subnets = {
  aks = { address_prefix = "10.0.1.0/24" }
  app = { address_prefix = "10.0.2.0/24" }
}
```

---

#### Module resource (`modules/network/main.tf`)

```hcl
resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  address_prefixes     = [each.value.address_prefix]
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
}
```

---

### 🧠 What’s happening

* Terraform creates one subnet **per map key**
* Keys become stable identities
* Adding/removing subnets is safe

---

## 2️⃣ `dynamic` Blocks (Conditional Nested Blocks)

### Problem

NSG rules are **nested blocks**, not resources.

You can’t do:

```hcl
count = 3
```

---

### Solution: `dynamic`

#### Variable (`modules/network/variables.tf`)

```hcl
variable "nsg_rules" {
  type = map(object({
    priority = number
    direction = string
    access = string
    protocol = string
    source = string
    destination = string
    port = string
  }))
}
```

---

#### Resource (`modules/network/main.tf`)

```hcl
dynamic "security_rule" {
  for_each = var.nsg_rules

  content {
    name                       = security_rule.key
    priority                   = security_rule.value.priority
    direction                  = security_rule.value.direction
    access                      = security_rule.value.access
    protocol                    = security_rule.value.protocol
    source_address_prefix       = security_rule.value.source
    destination_address_prefix  = security_rule.value.destination
    destination_port_range      = security_rule.value.port
  }
}
```

---

### 🧠 What’s happening

* Terraform expands this into multiple `security_rule` blocks
* Input-driven
* Zero duplication

---

## 3️⃣ Conditional Expressions (Environment Awareness)

### Root variable

```hcl
variable "environment" {
  type = string
}
```

---

### Conditional logic

```hcl
locals {
  enable_ddos = var.environment == "prod" ? true : false
}
```

---

### Usage

```hcl
enable_ddos_protection = local.enable_ddos
```

---

### Why this matters

* Same code
* Different behavior
* No branching files

---

## 4️⃣ `depends_on` (Explicit Graph Control)

Terraform usually infers dependencies, but sometimes it can’t.

### Example

```hcl
depends_on = [
  azurerm_virtual_network.this
]
```

Use this **only when required**.

---

## 5️⃣ Functions (Terraform’s Toolbox)

Examples:

```hcl
merge(map1, map2)
lookup(var.tags, "env", "dev")
try(var.optional, null)
```

### Example: Tag merging

```hcl
tags = merge(
  var.common_tags,
  {
    environment = var.environment
  }
)
```

---

## 6️⃣ Outputs from Iterated Resources

```hcl
output "subnet_ids" {
  value = {
    for k, s in azurerm_subnet.this : k => s.id
  }
}
```

This allows:

* Clean inter-module dependency
* Terragrunt usage later

---

## 7️⃣ Execution Flow (Important)

Terraform does:

1. Evaluate variables
2. Evaluate locals
3. Expand `for_each` / `dynamic`
4. Build dependency graph
5. Apply resources

Understanding this order helps debug *everything*.

---

## 🔥 Rules to Remember (Interview Gold)

* Prefer `for_each` over `count`
* Use `dynamic` only for nested blocks
* Conditionals should affect **values**, not structure (mostly)
* `depends_on` is a last resort
* Functions reduce duplication

---

## 📦 What You Achieved in Lab 7

You now:

* Write DRY Terraform
* Control infra dynamically
* Understand Terraform’s graph
* Are ready for complex AKS setups

---

## 🧠 Mental Shift

Terraform isn’t YAML.
It’s a **declarative graph language** with functional expressions.

Once this clicks, AKS modules become easy.

---

## 🔜 Next Lab (Lab 8 Preview)

**Azure Networking for AKS**

* VNets
* Subnets
* NSGs
* AKS-ready networking design

If you want:

* Say **“Lab 8 solution (deep explanation)”**
* Or **“Refactor Lab 7 for AKS networking”**

You’re officially past *intermediate Terraform* now 💪
