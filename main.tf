provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo-rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "demo-vn" {
  name                = var.vn_name
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name
  address_space       = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "demo-subnet" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.demo-rg.name
  virtual_network_name = azurerm_virtual_network.demo-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}


resource "azurerm_network_security_group" "demo-sg" {
  name                = "demo-sg"
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "demo-dev-rule" {
  name                        = "demo-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.demo-rg.name
  network_security_group_name = azurerm_network_security_group.demo-sg.name
}

# Now we associate security group to subnet to protect it.

resource "azurerm_subnet_network_security_group_association" "demo-sg-association" {
  subnet_id                 = azurerm_subnet.demo-subnet.id
  network_security_group_id = azurerm_network_security_group.demo-sg.id
}

# Now we create public ip for our VM way to internet

resource "azurerm_public_ip" "demo-ip" {
  name                = "demo-ip"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = azurerm_resource_group.demo-rg.location
  allocation_method   = "Dynamic"

  tags = var.tags
}

# We dont get ip after its creation, But once we deploy other resources we can then extract 
# ip address and use it. We create NIC and attach to our VM in order to provide 
# network connectivity. ThisNIC receives public ip tht we just created.

resource "azurerm_network_interface" "demo-nic" {
  name                = "demo-nic"
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
  name                = "demo-vm"
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