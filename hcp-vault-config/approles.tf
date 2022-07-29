# resource "vault_approle_auth_backend_role" "tfe-config" {
#   backend        = vault_auth_backend.approle.path
#   role_name      = "tfe-config"
#   token_policies = ["default"]
#   token_num_uses = 1
# }

resource "vault_approle_auth_backend_role" "wallace" {
  backend        = vault_auth_backend.approle.path
  role_name      = "wallace"
  token_policies = ["default", "admins"]
}

resource "vault_approle_auth_backend_role" "tfe-vault" {
  backend        = vault_auth_backend.approle.path
  role_name      = "tfe-vault"
  token_policies = ["default", "admins"]
  token_num_uses = 0
}

