resource "azurerm_virtual_network" "vnet" {
  name                = join("-", [var.prefix, "network"])
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = var.resource_group_name
  dns_servers         = ["10.0.1.4", "8.8.8.8"]
}

resource "azurerm_subnet" "domain-controllers" {
  name                 = "domain-controllers"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "domain_members" {
  name                 = "domain-members"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# security rule to accept RDP.
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-rdp-inbound-rule"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "3389-inbound-accept-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "3389"
    destination_port_range     = "*"
    source_address_prefix      = var.your_home_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "443-outbound-accept-rule"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}
