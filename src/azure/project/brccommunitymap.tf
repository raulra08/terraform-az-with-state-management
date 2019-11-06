# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version         = "=1.36.0"
  subscription_id = "${var.subscription}"
}

resource "azurerm_resource_group" "brc_resource_group" {
  location = "UK South"
  name     = "brc_resouce_group"
}

resource "azurerm_app_service_plan" "brc_app_service_plan" {
  name                = "brc-appserviceplan"
  location            = "${azurerm_resource_group.brc_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.brc_resource_group.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "brc_app_service" {
  name                = "community-map"
  location            = "${azurerm_resource_group.brc_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.brc_resource_group.name}"
  app_service_plan_id = "${azurerm_app_service_plan.brc_app_service_plan.id}"
  tags = {
      "approver"      = "${var.owner}"
      "environment"   = ""
      "managedBy"     = ""
      "nextReview"    = ""
      "operationsILA" = ""
      "owner"         = ""
      "project"       = "${var.project}"
      "projectILA"    = ""
      "purpose"       = ""
      "service"       = ""
      "serviceLevel"  = "noSLA",
      "creationDate"  = ""
  }
}