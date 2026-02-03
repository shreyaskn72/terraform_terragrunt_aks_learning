variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "system_node_vm_size" {
  type = string
}

variable "system_node_count" {
  type = number
}

variable "subnet_id" {
  type = string
}

variable "api_server_authorized_ips" {
  type        = list(string)
  description = "IP ranges allowed to access AKS API server"
}