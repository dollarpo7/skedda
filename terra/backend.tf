terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate1085"
    container_name       = "tfstate"
    key                  = "skedda.terraform.tfstate"
  }
}