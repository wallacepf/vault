output "consul_token" {
  value     = vault_token.consul.client_token
  sensitive = true
}

output "tfe_token" {
  value     = vault_token.tfe-admin.client_token
  sensitive = true
}

output "tfe_vault_demo_token" {
  value     = vault_token.tfe-vault-demo.client_token
  sensitive = true
}

# output "tfe_creds_secret_id" {
#   value     = vault_approle_auth_backend_role_secret_id.tfe-vault.secret_id
#   sensitive = true
# }

# output "tfe_creds_role_id" {
#   value = data.vault_approle_auth_backend_role_id.tfe-vault.role_id
# }