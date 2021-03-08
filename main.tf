resource "azurerm_resource_group" "server_rg" {
  name     = var.server_rg
  location = var.server_location
}

resource "azurerm_virtual_network" "server_vnet" {
  name                = "${var.server_resource_prefix}-vnet"
  location            = var.server_location
  resource_group_name = var.server_rg
  address_space       = [var.server_address_space]
  depends_on          = [azurerm_resource_group.server_rg]
}

resource "azurerm_subnet" "server_subnet" {
  name                 = "${var.server_resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.server_rg.name
  virtual_network_name = azurerm_virtual_network.server_vnet.name
  address_prefix       = var.server_address_prefix
}

# Allocation method is Dynamic for development environments
resource "azurerm_public_ip" "server_public_ip" {
  name                = "${var.server_name}-public-ip"
  location            = var.server_location
  resource_group_name = azurerm_resource_group.server_rg.name
  allocation_method   = var.environment == "production" ? "Static" : "Dynamic"
}

resource "azurerm_network_interface" "server_nic" {
  name                = "${var.server_name}-nic"
  location            = var.server_location
  resource_group_name = azurerm_resource_group.server_rg.name

  # Public IP address referenced by id <-- azurerm_public_ip
  ip_configuration {
    name                          = "${var.server_name}-ip"
    subnet_id                     = azurerm_subnet.server_subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.server_public_ip.id
  }
}

# Network interface referenced by id
resource "azurerm_linux_virtual_machine" "server_vm" {
  name                  = var.server_name
  location              = var.server_location
  resource_group_name   = azurerm_resource_group.server_rg.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.server_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("../../ssh/id_rsa.pub")
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
