# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version         = "=1.36.0"
  subscription_id = var.subscription
}

resource "azurerm_resource_group" "brc_infra_resourcegroup" {
    location = "westeurope"
    name     = "brc-base-infrastructure"
    tags     = {
        "approver"      = var.owner
        "environment"   = ""
        "managedBy"     = ""
        "nextReview"    = ""
        "operationsILA" = ""
        "owner"         = ""
        "project"       = var.project
        "projectILA"    = ""
        "purpose"       = ""
        "service"       = ""
        "serviceLevel"  = "noSLA",
        "creationDate"  = ""
    }
}
resource "azurerm_storage_account" "brc_infra_storage" {
    access_tier                    = "Hot"
    account_kind                   = "StorageV2"
    account_encryption_source      = "Microsoft.Storage"
    account_replication_type       = "LRS"
    account_tier                   = "Free"
    enable_blob_encryption         = true
    enable_file_encryption         = true
    enable_https_traffic_only      = true
    is_hns_enabled                 = false
    location                       = "westeurope"
    name                           = "${var.project}-terraform"
    resource_group_name            = azurerm_resource_group.brc_infra_resourcegroup.name
}

resource "azurerm_storage_container" "infrastructure_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.brc_infra_storage.name
  container_access_type = "private"
}
#Policy
