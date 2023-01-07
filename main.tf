provider "azurerm" {
  features {}
}

# Resource Group

resource "azurerm_resource_group" "demo-rg" {
  name     = "${var.project}-rg"
  location = var.location
  tags     = var.tags
}

# Virtual Network 

resource "azurerm_virtual_network" "demo-vn" {
  name                = "${var.project}-vn"
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnet

resource "azurerm_subnet" "demo-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.demo-rg.name
  virtual_network_name = azurerm_virtual_network.demo-vn.name
  address_prefixes     = var.subnet_addr_space
}

# Security Group

resource "azurerm_network_security_group" "demo-sg" {
  name                = var.sg_name
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name
  tags                = var.tags
}

# Creating Security Rule, with inbound access to My IP

resource "azurerm_network_security_rule" "demo-sg-rule" {
  name                        = "${var.sg_name}-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "165.225.121.31"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.demo-rg.name
  network_security_group_name = azurerm_network_security_group.demo-sg.name
}

# Associating security group to subnet to protect it.

resource "azurerm_subnet_network_security_group_association" "demo-sg-association" {
  subnet_id                 = azurerm_subnet.demo-subnet.id
  network_security_group_id = azurerm_network_security_group.demo-sg.id
}

# Creating public ip for our VM way to internet

resource "azurerm_public_ip" "demo-ip" {
  name                = "${var.project}-pip"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = azurerm_resource_group.demo-rg.location
  allocation_method   = "Dynamic"
  tags                = var.tags
}

resource "azurerm_network_interface" "demo-nic" {
  name                = "${var.project}-nic"
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo-ip.id
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "demo-vm" {
  name                = "${var.project}-vm"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = azurerm_resource_group.demo-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.demo-nic.id
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}