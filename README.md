## Terraform module for Linux virtual machine creation on Azure Cloud

#### Example usage
```terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {
  }
}

module "my_server" {
  source                 = "github.com/DuongVu98/terraform-azure-linux-vm-module"
  server_rg              = "project-rg"
  server_location        = "westus2"
  server_resource_prefix = "project-prefix"
  server_address_prefix  = "1.0.2.0/24"
  server_address_space   = "1.0.0.0/22"
  server_name            = "project-backend-server"
  vm_size                = "Standard_B2s"
  admin_username         = "tungduong"
  ssh_key_path           = "/home/tungduong/ssh/id_rsa.pub"
  environment            = "development"
}


```
