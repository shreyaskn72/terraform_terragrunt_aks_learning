

Below is a **hands-on lab plan mapped chapter-by-chapter**. Each lab is **small, practical, and cumulative**, so by the end you’ll have a **production-grade AKS platform** built the same way real teams do it.

> Assumption:
>
> * You have an Azure subscription
> * Azure CLI + kubectl installed
> * You’re working on Windows (works same on Linux)


If you want to go with theoretical approach Please refer the [Terraform + Terragrunt for AKS — Theoretical Guide](./theory.md)

---

# **Terraform + Terragrunt for AKS — Hands-On Labs**

---

## **PART 1: Foundations**

### **Lab 1: IaC & Tooling Setup**

**Goal:** Prepare your workstation

**Tasks**

* Install Terraform
* Install Terragrunt
* Install Azure CLI
* Login using:

  ```bash
  az login
  az account set --subscription "<subscription-id>"
  ```
* Create a Git repo:

  ```bash
  terraform-aks-labs/
  ```

**Deliverable**

* Screenshot or note showing tool versions
* Git repo initialized

Solution: [lab 1 solution](./lab-01)

---

### **Lab 2: First Terraform Deployment**

**Goal:** Deploy your first Azure resource

**Tasks**

* Create:

  * `main.tf`
  * `providers.tf`
* Deploy:

  * Resource Group
* Run:

  ```bash
  terraform init
  terraform plan
  terraform apply
  ```

**Deliverable**

* Resource Group visible in Azure Portal

---

Solutions: [lab 2 solution](./lab-02)

### **Lab 3: Azure Authentication**

**Goal:** Use secure authentication

**Tasks**

* Create a Service Principal
* Assign Contributor role
* Configure Terraform provider using:

  * Environment variables
* Validate deployment still works

**Deliverable**

* No credentials hardcoded in code

Solution: [lab 3 solution](./lab-03)

---

## **PART 2: Core Terraform Concepts**

### **Lab 4: Variables, Outputs & Locals**

**Goal:** Parameterize infrastructure

**Tasks**

* Create:

  * `variables.tf`
  * `outputs.tf`
* Move hardcoded values to variables
* Use locals for naming convention

**Deliverable**

* Environment-agnostic Terraform code

Solution: [lab 4 solution](./lab-04)

---

### **Lab 5: Remote State in Azure**

**Goal:** Safe state management

**Tasks**

* Create:

  * Storage Account
  * Blob Container
* Configure:

  ```hcl
  backend "azurerm"
  ```
* Migrate state:

  ```bash
  terraform init -migrate-state
  ```

**Deliverable**

* State stored in Azure Blob

Solution: [lab 5 solution](./lab-05)

---

### **Lab 6: Terraform Modules**

**Goal:** Reusable code

**Tasks**

* Create a module:

  ```
  modules/resource-group/
  ```
* Move RG code into module
* Call module from root

**Deliverable**

* Reusable RG module

Solution: [lab 6 solution](./lab-06)

---

### **Lab 7: Advanced Terraform Language**

**Goal:** Dynamic infrastructure

**Tasks**

* Use `for_each` to create:

  * Multiple subnets
* Use `dynamic` blocks for NSG rules
* Use `depends_on`

**Deliverable**

* Parameterized networking resources

Solution: [lab 7 solution](./lab-07)

---

## **PART 3: Azure Networking for AKS**

### **Lab 8: VNet & Subnets**

**Goal:** AKS-ready network

**Tasks**

* Create:

  * VNet
  * AKS subnet
  * App subnet
* Attach NSGs

**Deliverable**

* Network visible in Azure


Solution: [lab 8 solution](./lab-08)

---

### **Lab 9: AKS Networking Model**

**Goal:** Choose correct CNI

**Tasks**

* Deploy:

  * AKS using Azure CNI
* Validate:

  ```bash
  kubectl get nodes -o wide
  ```

**Deliverable**

* Pods receive VNet IPs

Solution: [lab 9 solution](./lab-09)

---

## **PART 4: Deploying AKS**

### **Lab 10: Basic AKS Cluster**

**Goal:** First working AKS

**Tasks**

* Create AKS cluster
* Enable:

  * System node pool
* Connect using:

  ```bash
  az aks get-credentials
  ```

**Deliverable**

* `kubectl get nodes` works

Solution: [lab 10 solution](./lab-10)

---

### **Lab 11: AKS Identity & RBAC**

**Goal:** Secure cluster

**Tasks**

* Enable:

  * Managed Identity
  * Azure RBAC
* Assign user access
* Test:

  ```bash
  kubectl auth can-i get pods
  ```

**Deliverable**

* RBAC enforced

Solution: [lab 11 solution](./lab-11)

---

### **Lab 12: AKS Storage & Add-ons**

**Goal:** Production add-ons

**Tasks**

* Enable:

  * Azure Monitor
  * Log Analytics
* Deploy PVC using Azure Disk
* Validate logs in Azure Portal

**Deliverable**

* Persistent storage working

Solution: [lab 12 solution](./lab-12)

---

### **Lab 13: Advanced AKS Config**

**Goal:** Real-world tuning

**Tasks**

* Add:

  * User node pool
  * Autoscaling
* Create:

  * Spot node pool
* Perform node pool upgrade

**Deliverable**

* Multi-pool AKS cluster

Solution: [lab 13 solution](./lab-13)

---

## **PART 5: Terragrunt**

### **Lab 14: Terragrunt Basics**

**Goal:** DRY Terraform

**Tasks**

* Convert Terraform project to Terragrunt
* Create:

  ```hcl
  terragrunt.hcl
  ```
* Run:

  ```bash
  terragrunt init
  terragrunt apply
  ```

**Deliverable**

* Same infra, less code

Solution: [lab 14 solution](./lab-14)

---

### **Lab 15: Remote State via Terragrunt**

**Goal:** Centralized state

**Tasks**

* Configure remote state in Terragrunt
* Remove backend from Terraform code

**Deliverable**

* State fully managed by Terragrunt

Solution: [lab 15 solution](./lab-15)

---

### **Lab 16: Terragrunt Folder Structure**

**Goal:** Multi-env layout

**Tasks**

* Create:

  ```
  live/dev
  live/stage
  live/prod
  ```
* Reuse same modules

**Deliverable**

* Environment isolation

Solution: [lab 16 solution](./lab-16)

---

### **Lab 17: Dependencies**

**Goal:** Ordered deployments

**Tasks**

* Add `dependency` blocks
* Pass VNet ID to AKS module
* Apply in correct order

**Deliverable**

* Zero manual wiring

Solution: [lab 17 solution](./lab-17)

---

### **Lab 18: Multi-Environment AKS**

**Goal:** Real org setup

**Tasks**

* Deploy:

  * Dev AKS
  * Prod AKS
* Use different node sizes

**Deliverable**

* Multiple AKS clusters safely managed


Solution: [lab 18 solution](./lab-18)


---

## **PART 6: Production Readiness**

### **Lab 19: Security Hardening**

**Goal:** Secure AKS

**Tasks**

* Deploy:

  * Private AKS cluster
* Enable:

  * Network policies
* Restrict API access

**Deliverable**

* Private AKS validated

Solution: [lab 19 solution](./lab-19)

---

### **Lab 20: CI/CD Integration**

**Goal:** Automated infra

**Tasks**

* Create GitHub Actions pipeline
* Run:

  * terraform plan
  * terraform apply (manual approval)

**Deliverable**

* CI/CD pipeline working

---

### **Lab 21: Day-2 Operations**

**Goal:** Operate safely

**Tasks**

* Upgrade Kubernetes version
* Scale node pools
* Simulate failure & recover

**Deliverable**

* Zero-downtime ops

---

## **PART 7: Debugging**

### **Lab 22: Failure Scenarios**

**Goal:** Troubleshooting

**Tasks**

* Break state file (intentionally)
* Fix via:

  ```bash
  terraform state list
  terraform state rm
  ```

**Deliverable**

* Confidence in fixing issues

---

### **Lab 23: Anti-Patterns**

**Goal:** Learn from mistakes

**Tasks**

* Identify:

  * Hardcoded secrets
  * Large root modules
* Refactor

**Deliverable**

* Clean, maintainable code

---

## **PART 8: Capstone**

### **Lab 24: End-to-End AKS Platform**

**Goal:** Portfolio-ready project

**Tasks**

* Multi-env AKS
* Private networking
* CI/CD
* Monitoring
* Security best practices

**Deliverable**

* GitHub repo you can show in interviews 🚀


---