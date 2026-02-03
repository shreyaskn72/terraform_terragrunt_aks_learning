variable "resource_group_name" {
  type        = string
  description = "Name of the resource group for AKS"
}

variable "location" {
  type        = string
  description = "Azure region for AKS"
}

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for AKS node pool"
}
