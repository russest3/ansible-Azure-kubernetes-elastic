terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

########## RESOURCE GROUP #################################
resource "azurerm_resource_group" "test" {
  name     = var.rg
  location = var.location
}
##########################################################



############### NETWORK CONFIG############################
resource "azurerm_virtual_network" "main" {
  name                = "${var.env}-network"
  address_space       = ["10.0.0.0/25"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/27"]
}

resource "azurerm_network_interface" "jumpbox" {
    name                = "${var.env}-jumpbox"
    location            = azurerm_resource_group.test.location
    resource_group_name = azurerm_resource_group.test.name

    ip_configuration {
      name                          = "jumpbox-nic1"
      subnet_id                     = azurerm_subnet.internal.id
      private_ip_address_allocation = "Dynamic"
    }
}

# resource "azurerm_network_interface" "c1-cp1" {
#   name                = "${var.env}-c1-cp1-nic1"
#   location            = azurerm_resource_group.test.location
#   resource_group_name = azurerm_resource_group.test.name

#   ip_configuration {
#     name                          = "c1-cp1-nic1"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_network_interface" "c1-node1" {
#   name                = "${var.env}-c1-node1-nic1"
#   location            = azurerm_resource_group.test.location
#   resource_group_name = azurerm_resource_group.test.name

#   ip_configuration {
#     name                          = "c1-node1-nic1"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_network_interface" "c1-node2" {
#   name                = "${var.env}-c1-node2-nic1"
#   location            = azurerm_resource_group.test.location
#   resource_group_name = azurerm_resource_group.test.name

#   ip_configuration {
#     name                          = "c1-node2-nic1"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_network_interface" "c1-node3" {
#   name                = "${var.env}-c1-node3-nic1"
#   location            = azurerm_resource_group.test.location
#   resource_group_name = azurerm_resource_group.test.name

#   ip_configuration {
#     name                          = "c1-node3-nic1"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }
##############################################################




############### CONTROL PLANE NODE #####################
# resource "azurerm_linux_virtual_machine" "c1-cp1" {
#   name                  = "${var.env}-${var.vmname}"
#   location              = azurerm_resource_group.test.location
#   resource_group_name   = azurerm_resource_group.test.name
#   network_interface_ids = [azurerm_network_interface.c1-cp1.id]
#   # size                  = "Standard_DS1_v2"
#   size                  = "Standard_A2_v2"
#   admin_username        = var.admin_name
#   admin_password        = var.admin_pw
#   disable_password_authentication = false
#   custom_data = filebase64("script.tftpl")
#   admin_ssh_key {
#     username = var.admin_name
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   lifecycle {
#     ignore_changes = [ 
#       admin_password,
#      ]
#   }

#   source_image_reference {
#     publisher           = var.image_publisher
#     offer               = var.image_offer
#     sku                 = var.image_sku
#     version             = var.image_version
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   tags = {
#     environment = var.env
#   }
# }
#######################################

####### BASTION HOST  ################################
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.32/27"]
}

resource "azurerm_network_security_group" "vm_subnet_nsg" {
  name                = "nsg-vm-subnet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "inbound_allow_ssh" {
  network_security_group_name = azurerm_network_security_group.vm_subnet_nsg.name
  resource_group_name         = azurerm_resource_group.test.name
  name                        = "Inbound_Allow_Bastion_SSH"
  priority                    = 510
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_subnet.bastion_subnet.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.internal.address_prefixes[0]
}

resource "azurerm_network_security_rule" "inbound_allow_rdp" {
  network_security_group_name = azurerm_network_security_group.vm_subnet_nsg.name
  resource_group_name         = azurerm_resource_group.test.name
  name                        = "Inbound_Allow_Bastion_RDP"
  priority                    = 515
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = azurerm_subnet.bastion_subnet.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.internal.address_prefixes[0]
}

resource "azurerm_public_ip" "bastion_ip" {
  name                = "${var.env}-public-ip"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "c1-bastion" {
  name                = "${var.env}-${var.bh_name}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  tunneling_enabled   = true
  ip_connect_enabled  = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}
##################################




################# Windows 10 VM ##################################
resource "azurerm_windows_virtual_machine" "jumpbox" {
  name                  = "${var.env}-${var.jumpbox_name}"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [azurerm_network_interface.jumpbox.id]
  size                  = "Standard_B2s"
  admin_username        = var.admin_name
  admin_password        = var.admin_pw

  # lifecycle {
  #   ignore_changes = [ 
  #     admin_password,
  #    ]
  # }

  source_image_reference {
    publisher           = "MicrosoftWindowsDesktop"
    offer               = "Windows-10"
    sku                 = "win10-22h2-pro"
    version             = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = var.env
  }
}
##################################################################




################# WORKER NODE C1-NODE1 ############################
# resource "azurerm_linux_virtual_machine" "c1-node1" {
#   name                  = "${var.env}-${var.workernode1_name}"
#   location              = azurerm_resource_group.test.location
#   resource_group_name   = azurerm_resource_group.test.name
#   network_interface_ids = [azurerm_network_interface.c1-node1.id]
#   custom_data = filebase64("script.tftpl")
#   size                  = "Standard_A2_v2"
#   admin_username        = var.admin_name
#   admin_password        = var.admin_pw
#   disable_password_authentication = false
#   admin_ssh_key {
#     username = var.admin_name
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   lifecycle {
#     ignore_changes = [ 
#       admin_password,
#      ]
#   }

#   source_image_reference {
#     publisher           = var.image_publisher
#     offer               = var.image_offer
#     sku                 = var.image_sku
#     version             = var.image_version
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   tags = {
#     environment = var.env
#   }
# }
#################################################################



################# WORKER NODE C1-NODE2 ############################
# resource "azurerm_linux_virtual_machine" "c1-node2" {
#   name                  = "${var.env}-${var.workernode2_name}"
#   location              = azurerm_resource_group.test.location
#   resource_group_name   = azurerm_resource_group.test.name
#   network_interface_ids = [azurerm_network_interface.c1-node2.id]
#   custom_data = filebase64("script.tftpl")
#   size                  = "Standard_A2_v2"
#   admin_username        = var.admin_name
#   admin_password        = var.admin_pw
#   disable_password_authentication = false
#   admin_ssh_key {
#     username = var.admin_name
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   lifecycle {
#     ignore_changes = [ 
#       admin_password,
#      ]
#   }

#   source_image_reference {
#     publisher           = var.image_publisher
#     offer               = var.image_offer
#     sku                 = var.image_sku
#     version             = var.image_version
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   tags = {
#     environment = var.env
#   }
# }
#################################################################



################# WORKER NODE C1-NODE3 ############################
# resource "azurerm_linux_virtual_machine" "c1-node3" {
#   name                  = "${var.env}-${var.workernode3_name}"
#   location              = azurerm_resource_group.test.location
#   resource_group_name   = azurerm_resource_group.test.name
#   network_interface_ids = [azurerm_network_interface.c1-node3.id]
#   custom_data = filebase64("script.tftpl")
#   size                  = "Standard_A2_v2"
#   admin_username        = var.admin_name
#   admin_password        = var.admin_pw
#   disable_password_authentication = false
#   admin_ssh_key {
#     username = var.admin_name
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   lifecycle {
#     ignore_changes = [ 
#       admin_password,
#      ]
#   }

#   source_image_reference {
#     publisher           = var.image_publisher
#     offer               = var.image_offer
#     sku                 = var.image_sku
#     version             = var.image_version
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#    tags = {
#     environment = var.env
#   }
# }
#################################################################
