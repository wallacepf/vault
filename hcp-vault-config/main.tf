terraform {
  cloud {
    organization = "my-demo-account"
    workspaces {
      name = "hcp-vault-configs"
    }
  }
  required_providers {
    vault = {
      version = "~> 3.4.1"
    }
  }
}

data "tfe_outputs" "vault" {
  organization = var.org
  workspace    = "hcp-vault"
}

data "tfe_outputs" "consul" {
  organization = var.org
  workspace    = "hcp-consul"
}

provider "vault" {
  address   = data.tfe_outputs.vault.values.vault_public_addr
  namespace = data.tfe_outputs.vault.values.vault_ns
}
