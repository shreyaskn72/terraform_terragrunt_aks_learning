variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}