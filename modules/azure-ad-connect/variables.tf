variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "upn_suffix_for_aad_synchronization" {
  description = "custom domain set up on Azure AD. This will be alternative upn suffix on Active Directory."
}
variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "subnet_id" {
  description = "Subnet ID for the Domain Controllers"
}

variable "active_directory_domain_name" {
  description = "the domain name for Active Directory, for example `consoto.local`"
}

variable "admin_username" {
  description = "Username for the Domain Administrator user"
}

variable "admin_password" {
  description = "Password for the Adminstrator user"
}

variable "active_directory_username" {
  description = "The username of an account with permissions to bind machines to the Active Directory Domain"
}

variable "active_directory_password" {
  description = "The password of the account with permissions to bind machines to the Active Directory Domain"
}

variable "rdp_inbound_nsg_id" {
  description = "RDP inbound rule for nic"
}

locals {
  virtual_machine_name = join("-", [var.prefix, "aadc"])
  aadc_install_command = "msiexec.exe /i https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi /qn /passive"
  install_rsat_command = "Install-WindowsFeature RSAT-AD-Tools"
}
