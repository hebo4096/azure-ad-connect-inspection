variable "prefix" {
  description = "The prefix which should be used for all resources in this example (note: max character is 8)"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
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

variable "active_directory_netbios_name" {
  description = "The netbios name of the Active Directory domain, for example `consoto`"
}

variable "admin_username" {
  description = "Username for the Domain Administrator user"
}

variable "admin_password" {
  description = "Password for the Adminstrator user"
}

variable "rdp_inbound_nsg_id" {
  description = "RDP inbound rule for nic"
}

locals {
  virtual_machine_name = join("-", [var.prefix, "dc"])
  virtual_machine_fqdn = join(".", [local.virtual_machine_name, var.active_directory_domain_name])

  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force"
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.active_directory_domain_name} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  powershell_command   = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}
