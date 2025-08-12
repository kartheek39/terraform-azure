
resource "azurerm_resource_group" "practice_rg" {
    name = "practice-rg"
    location = "eastus"
}

resource "azurerm_virtual_network" "practice_vnet" {
  name = "practice-vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.practice_rg.location
  resource_group_name = azurerm_resource_group.practice_rg.name
}

resource "azurerm_subnet" "practice_subnet_pub" {
  name = "practice-sub-pub"
  resource_group_name = azurerm_resource_group.practice_rg.name
  virtual_network_name = azurerm_virtual_network.practice_vnet.name
  address_prefixes = ["10.10.2.0/24"]
}

resource "azurerm_network_interface" "practice_nic" {
  name = "practice-nic-01"
  location = azurerm_resource_group.practice_rg.location
  resource_group_name = azurerm_resource_group.practice_rg.name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.practice_subnet_pub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "practice_vm" {
  name                = "practice-vm"
  resource_group_name = azurerm_resource_group.practice_rg.name
  location            = azurerm_resource_group.practice_rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password = "KCyber@12345"
  network_interface_ids = [
    azurerm_network_interface.practice_nic.id,
  ]

  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
