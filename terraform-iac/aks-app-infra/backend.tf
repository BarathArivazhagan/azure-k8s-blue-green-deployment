terraform {
  backend "azurerm" {
    resource_group_name  = "demo-terraform-state"
    storage_account_name = "terraformstate"
    container_name       = "tfstate"
    key                  = "eastcoast.terraform.tfstate"
    use_azuread_auth     = true
  }
}