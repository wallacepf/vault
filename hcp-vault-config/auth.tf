resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "u1" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/consul_operator"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["default"],
  "password": "${var.consul_operator_pwd}",
  "token_ttl": "1h"
}
EOT
}

resource "vault_identity_entity" "consul_operator" {
  name = "consul_operator"
  metadata = {
    email        = "consuldemo@hashicorp.com",
    phone_number = "+5511975483134"
  }
}

resource "vault_identity_group" "operators" {
  name              = "operators"
  member_entity_ids = [vault_identity_entity.consul_operator.id]

}

resource "vault_identity_entity_alias" "test" {
  name           = vault_identity_entity.consul_operator.name
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.consul_operator.id
}

