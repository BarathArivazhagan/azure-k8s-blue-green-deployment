locals {

  rg_name     = var.rg_name
  common_tags = var.common_tags

}


module "resource_group" {
  source   = "../modules/resource_group"
  location = var.location
  rg_name  = var.rg_name
  tags     = var.common_tags
}

module "virtual_network" {
  source              = "Azure/network/azurerm"
  resource_group_name = module.resource_group.rg_name
  vnet_name           = var.vnet_name
  address_spaces      = var.vnet_cidr_blocks
  subnet_prefixes     = var.subnet_cidr_blocks
  subnet_names        = var.subnet_names
  tags                = local.common_tags
  depends_on = [module.resource_group]
}