resource "azurerm_public_ip" "member_static" {
  name                = "${var.prefix}-member-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-member"
}

resource "azurerm_network_interface" "member_nic" {
  name                = "${var.prefix}-member-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "member-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.member_static.id
  }
}

# associations for network security group and domain member nic
resource "azurerm_network_interface_security_group_association" "domain_member_nic_association" {
  network_interface_id      = azurerm_network_interface.member_nic.id
  network_security_group_id = var.rdp_inbound_nsg_id
}

resource "azurerm_windows_virtual_machine" "domain_member" {
  name                     = local.virtual_machine_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  size                     = "Standard_F2"
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  provision_vm_agent       = true
  enable_automatic_updates = true

  network_interface_ids = [
    azurerm_network_interface.member_nic.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "wait_for_domain_to_provision" {
  name                 = "TestConnectionDomain"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_member.id
  settings             = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"while (!(Test-Connection -ComputerName ${var.active_directory_domain_name} -Count 1 -Quiet) -and ($retryCount++ -le 360)) { Start-Sleep 10 } \""
  }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "join_domain" {
  name                 = azurerm_windows_virtual_machine.domain_member.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  virtual_machine_id   = azurerm_windows_virtual_machine.domain_member.id

  settings = <<SETTINGS
    {
        "Name": "${var.active_directory_domain_name}",
        "OUPath": "",
        "User": "${var.active_directory_username}@${var.active_directory_domain_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.active_directory_password}"
    }
SETTINGS

  depends_on = [azurerm_virtual_machine_extension.wait_for_domain_to_provision]
}
