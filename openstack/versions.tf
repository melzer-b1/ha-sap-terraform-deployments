
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  tenant_name = var.project
  # user_name   = "admin"
  # password    = "pwd"
  auth_url    = var.openstack_auth_url
  region      = var.region
}

