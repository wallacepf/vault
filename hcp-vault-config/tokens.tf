resource "vault_token" "consul" {
  policies  = ["consul-policy"]
  ttl       = "768h"
  renewable = true
  no_parent = true
}

resource "vault_token" "tfe-admin" {
  policies  = ["admins"]
  ttl       = "768h"
  renewable = true
  no_parent = true
}

resource "vault_token" "tfe-vault-demo" {
  policies  = ["awsdemo-policy", "default"]
  ttl       = "768h"
  renewable = true
  no_parent = true
}
