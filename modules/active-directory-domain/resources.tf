resource "azurerm_public_ip" "static" {
  name                = "${var.prefix}-dc-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-dc"
}

resource "azurerm_network_interface" "dc_nic" {
  name                = "${var.prefix}-dc-primary"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "dc-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    public_ip_address_id          = azurerm_public_ip.static.id
  }
}

# associations for network security group and domain controller nic
resource "azurerm_network_interface_security_group_association" "domain_member_nic_association" {
  network_interface_id = azurerm_network_interface.dc_nic.id
  network_security_group_id = var.rdp_inbound_nsg_id
}

resource "azurerm_windows_virtual_machine" "domain_controller" {
  name                = local.virtual_machine_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.dc_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "create_ad_forest" {
  name                 = "create-active-directory-forest"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_controller.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
  }
SETTINGS
}
