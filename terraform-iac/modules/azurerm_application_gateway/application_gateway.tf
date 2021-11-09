locals {
  backend_address_pool_name      = join("-",[var.vnet_name,"beap"])
  frontend_port_name             = join("-",[var.vnet_name,"feport"])
  frontend_ip_configuration_name = join("-",[var.vnet_name,"feip"])
  http_setting_name              = join("-",[var.vnet_name,"be-htst"])
  listener_name                  = join("-",[var.vnet_name,"httplstn"])
  request_routing_rule_name      = join("-",[var.vnet_name,"rqrt"])
  redirect_configuration_name    = join("-",[var.vnet_name,"rdrcfg"])
}

resource "azurerm_subnet" "app_gw_subnet" {
  name                 = "backend"
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.app_gw_subnet_cidr_block]
}

resource "azurerm_public_ip" "app_gw_frontend_ip" {
  name                = var.app_gw_public_ip_name
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = var.allocation_method
}

resource "azurerm_application_gateway" "application_gateway" {
  name                = var.app_gw_name
  resource_group_name = var.rg_name
  location            =  var.location

  sku {
    name     = var.app_gw_sku_name
    tier     = var.app_gw_sku_tier
    capacity = var.app_gw_capacity
  }

  gateway_ip_configuration {
    name      = join("-",[var.app_gw_name,var.app_gw_public_ip_name])
    subnet_id = azurerm_subnet.app_gw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = join("-",[var.app_gw_public_ip_name,"configuration"])
    public_ip_address_id = azurerm_public_ip.app_gw_frontend_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}