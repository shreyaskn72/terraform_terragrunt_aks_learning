variable "location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}

variable "nsg_rules" {
  type = map(object({
    priority    = number
    direction   = string
    access      = string
    protocol    = string
    source      = string
    destination = string
    port        = string
  }))
}

variable "common_tags" {
  type = map(string)
}