output "domain_controllers_subnet_id" {
  value = azurerm_subnet.domain_controllers.id
}

output "domain_members_subnet_id" {
  value = azurerm_subnet.domain_members.id
}

output "rdp_inbound_rule_nsg_id" {
  value = azurerm_network_security_group.this.id
}
