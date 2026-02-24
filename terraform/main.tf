
# creat resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# create virtual network

resource "azurerm_virtual_network" "vnet" {
  name                = "lighthouse-vnet"
  address_space       = ["10.39.0.0/22"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# create subnet


resource "azurerm_subnet" "subnet" {
  name                 = "lighthouse-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.39.1.0/24"]
}

# create public IP address


resource "azurerm_public_ip" "public_ip" {
  name                = "lighthouse-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# create network security group

resource "azurerm_network_security_group" "nsg" {
  name                = "lighthouse-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# create network security rule to allow inbound traffic on port 4008



resource "azurerm_network_security_rule" "allow_4008" {
  name                        = "Allow-4008"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  destination_port_range      = "4008"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name



}

