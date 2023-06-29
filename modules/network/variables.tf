variable "prefix" {
  description = "The prefix which should be used for all resources in this example (note: max character is 8)"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "your_home_ip" {
  description = "IP for nsg inbound rule"
}
