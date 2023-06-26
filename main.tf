provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  location = var.location
  name     = "${var.prefix}-rg"
}


module "network" {
  source = "./modules/network"

  location            = var.location
  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.example.name
  your_home_ip        = var.your_home_ip
}

module "active_directory_domain" {
  source = "./modules/active-directory-domain"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  active_directory_domain_name  = var.custom_domain
  active_directory_netbios_name = split(".", var.custom_domain)[0]
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  prefix                        = var.prefix
  subnet_id                     = module.network.domain_controllers_subnet_id
  rdp_inbound_nsg_id            = module.network.rdp_inbound_rule_nsg_id
}

module "active_directory_member" {
  source = "./modules/domain-member"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  prefix              = var.prefix

  active_directory_domain_name = var.custom_domain
  active_directory_username    = var.admin_username
  active_directory_password    = var.admin_password
  admin_username               = var.admin_username
  admin_password               = var.admin_password
  subnet_id                    = module.network.domain_members_subnet_id
  rdp_inbound_nsg_id           = module.network.rdp_inbound_rule_nsg_id
}

module "azure_ad_connect" {
  source = "./modules/azure-ad-connect"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  prefix              = var.prefix

  active_directory_domain_name       = var.custom_domain
  active_directory_username          = var.admin_username
  active_directory_password          = var.admin_password
  upn_suffix_for_aad_synchronization = var.custom_domain
  admin_username                     = var.admin_username
  admin_password                     = var.admin_password
  subnet_id                          = module.network.domain_members_subnet_id
  rdp_inbound_nsg_id                 = module.network.rdp_inbound_rule_nsg_id
}
