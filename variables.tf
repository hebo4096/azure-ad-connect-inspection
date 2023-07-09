variable "prefix" {
  description = "The prefix which should be used for all resources in this example (note: max character is 8)"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "admin_username" {
  description = "Username for the Administrator account."
}

variable "admin_password" {
  description = "Password for the Administrator account."
}

variable "your_home_ip" {
  description = "IP used for RDP inbound rule."
}

variable "custom_domain" {
  description = "set custom domain for synchronization on your Azure AD environment."
}
