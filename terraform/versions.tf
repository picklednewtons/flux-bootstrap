terraform {
  required_version = ">= 1.3.0"
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.24.2"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.2.3"
    }
  }
}