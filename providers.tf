terraform {
  required_version = ">=1.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}
#Production
provider "azurerm" {
  features {}
  alias = "production"
  subscription_id   = "b5b7ea01-6fc3-4175-b04c-bb6ec3e013e2"
  tenant_id         = "dd63fb60-07f6-4d96-8d40-ebeca61a524e"
  client_id         = "af717aff-ae65-4084-9d91-2022e36341f0"
  client_secret     = "2d1b7b0b-5f83-4fe4-a0f3-a75f1756abdc" 
}
#Non-Production/test
provider "azurerm" {
  features {}
  alias = "non-prod"
  subscription_id   = "648cfaef-a25b-4fb6-acf7-0059be4e2108"
  tenant_id         = "dd63fb60-07f6-4d96-8d40-ebeca61a524e"
  client_id         = "cfd5739f-72e3-4e97-9125-ccee10529270"
  client_secret     = "bd9c1642-64a0-488a-afd9-974c5ac43b02" 
}