variable "resource_group_name" {
  default = "rg-lab-11"
}

variable "location" {
  default = "East US"
}

variable "cluster_name" {
  default = "aks-lab-11"
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for AKS admins"
  type        = list(string)
}