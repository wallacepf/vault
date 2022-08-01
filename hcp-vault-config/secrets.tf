locals {
  user_scope_template   = "{ \"username\": {{identity.entity.name}}, \"contact\": { \"email\": {{identity.entity.metadata.email}}, \"phone_number\": {{identity.entity.metadata.phone_number}} } }"
  groups_scope_template = "{ \"groups\": {{identity.entity.groups.names}} }"
}

resource "vault_terraform_cloud_secret_backend" "terraform" {
  backend     = "terraform"
  description = "Manages the Terraform Cloud backend"
  token       = var.tfe_token
}

resource "vault_aws_secret_backend" "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "vault_mount" "kv-v2" {
  path = "secret"
  type = "kv-v2"
}

resource "vault_identity_oidc_assignment" "default" {
  name = "assignment"
  entity_ids = [
    vault_identity_entity.consul_operator.name,
  ]
  group_ids = [
    vault_identity_group.operators.name,
  ]
}

resource "vault_identity_oidc_key" "my_key" {
  name               = "my-key"
  allowed_client_ids = ["*"]
  rotation_period    = 3600
  verification_ttl   = 7200
  algorithm          = "RS256"
}

resource "vault_identity_oidc_client" "consul" {
  name = "consul"
  key  = vault_identity_oidc_key.my_key.name
  redirect_uris = [
    "https://consul-pov-11814103.consul.5bbc50e3-a284-4743-877e-ffd388d684f2.aws.hashicorp.cloud/oidc/callback",
    "https://consul-pov-11814103.consul.5bbc50e3-a284-4743-877e-ffd388d684f2.aws.hashicorp.cloud/ui/oidc/callback"
  ]
  assignments = [
    vault_identity_oidc_assignment.default.name
  ]
  id_token_ttl     = 1800
  access_token_ttl = 3600
}

# resource "vault_identity_oidc_scope" "users" {
#   name = "users"
#   template = jsonencode(
#     {
#       username = "{{identity.entity.name}}",
#       contact = {
#         email = "{{identity.entity.metadata.email}}",
#         phone_number = "{{identity.entity.metadata.phone_number}}",
#       }
#     }
#   )
#   description = "Users scope."
# }

# resource "vault_identity_oidc_scope" "groups" {
#   name = "groups"
#   template = jsonencode(
#     {
#       "groups" = "{{identity.entity.groups.names}}"
#     }
#   )
#   description = "Groups scope."
# }

resource "vault_generic_endpoint" "user_scope" {
  lifecycle {
    # replace_triggered_by = [
    #   vault_identity_entity.consul_operator,
    #   vault_identity_group.operators
    # ]
    ignore_changes = [
      data_json
    ]
  }

  ignore_absent_fields = true

  path      = "identity/oidc/scope/user"
  data_json = <<EOT
{
  "description": "Users scope",
  "template": "${base64encode(local.user_scope_template)}"
}
EOT
}

resource "vault_generic_endpoint" "group_scope" {
  lifecycle {
    # replace_triggered_by = [
    #   vault_identity_entity.consul_operator,
    #   vault_identity_group.operators
    # ]
    ignore_changes = [
      data_json
    ]
  }

  ignore_absent_fields = true

  path      = "identity/oidc/scope/groups"
  data_json = <<EOT
{
  "description": "Group scope",
  "template": "${base64encode(local.groups_scope_template)}"
}
EOT
}

resource "vault_identity_oidc_provider" "oidc_provider" {
  name          = "vault-oidc"
  https_enabled = true
  issuer_host   = "hcp-vault-demo.private.vault.5bbc50e3-a284-4743-877e-ffd388d684f2.aws.hashicorp.cloud:8200"
  allowed_client_ids = [
    vault_identity_oidc_client.consul.client_id
  ]
  scopes_supported = [
    "user",
    "groups"
  ]
}

resource "vault_consul_secret_backend" "consul" {
  path        = "consul"
  description = "Manages the Consul backend"

  address = data.tfe_outputs.consul.values.consul_public_endpoint
  token   = data.tfe_outputs.consul.values.consul_root_token
}

resource "vault_consul_secret_backend_role" "op_ro" {
  name    = "operator-ro"
  backend = vault_consul_secret_backend.consul.path

  policies = [
    "oidc_ro",
  ]
}

resource "vault_consul_secret_backend_role" "op_rw" {
  name    = "operator-rw"
  backend = vault_consul_secret_backend.consul.path

  policies = [
    "oidc_rw",
  ]
}

# resource "vault_mount" "root_ca" {
#   path = "connect_root"
#   type = "pki"
#   default_lease_ttl_seconds = 8640000
#   max_lease_ttl_seconds = 8640000
# }

# resource "vault_mount" "pki_int" {
#   path = "connect_inter"
#   type = "pki"
#   default_lease_ttl_seconds = 86400
#   max_lease_ttl_seconds = 86400
# }

# resource "vault_pki_secret_backend_root_cert" "example" {
#   backend              = vault_mount.root_ca.path
#   type                 = "internal"
#   common_name          = "dc1.consul"
#   ttl                  = 86400
#   format               = "pem"
#   private_key_format   = "der"
#   key_type             = "ec"
#   key_bits             = 256
#   exclude_cn_from_sans = true
# }

# resource "vault_pki_secret_backend_intermediate_cert_request" "example" {
#   backend     = vault_mount.pki_int.path
#   type        = vault_pki_secret_backend_root_cert.example.type
#   common_name = "SubOrg Intermediate CA"
# }

# resource "vault_pki_secret_backend_root_sign_intermediate" "example" {
#   backend              = vault_mount.root_ca.path
#   csr                  = vault_pki_secret_backend_intermediate_cert_request.example.csr
#   common_name          = "dc1.consul Intermediate Authority"
#   exclude_cn_from_sans = true
#   ou                   = "SubUnit"
#   organization         = "SubOrg"
#   country              = "US"
#   locality             = "San Francisco"
#   province             = "CA"
#   # revoke               = true
# }

# resource "vault_pki_secret_backend_intermediate_set_signed" "example" {
#   backend     = vault_mount.pki_int.path
#   certificate = vault_pki_secret_backend_root_sign_intermediate.example.certificate
# }

# resource "vault_pki_secret_backend_root_cert" "root_cert" {
#   depends_on = [
#     vault_mount.root_ca
#   ]
#   backend = vault_mount.root_ca.path
#   type = "internal"
#   common_name = "testlab.com"
#   ttl = 3 * 366 * 24 * 60 * 60
#   format = "pem"
#   private_key_format = "der"
#   key_type = "ec"
#   key_bits = 256
#   exclude_cn_from_sans = "true"
#   organization = "Test Company"
# }

# data "tfe_outputs" "vault_addr" {
#   organization = "my-demo-account"
#   workspace = "hcp-vault"
# }

# resource "vault_pki_secret_backend_config_urls" "root_url" {
#   backend = vault_mount.root_ca.path
#   issuing_certificates = [ "${data.tfe_outputs.vault_addr.values.vault_addr}/v1/${vault_mount.root_ca.path}/ca" ]
#   crl_distribution_points = [ "${data.tfe_outputs.vault_addr.values.vault_addr}/v1/${vault_mount.root_ca.path}/crl" ]
# }

# resource "vault_pki_secret_backend_crl_config" "crl_config" {
#   backend = vault_mount.root_ca.path
#   expiry = "26280h"
#   disable = false
# }

# resource "vault_pki_secret_backend_role" "role" {
#   backend = vault_mount.root_ca.path
#   name = "mtls"

#   allow_any_name = true
#   enforce_hostnames = false
#   allow_ip_sans = false
#   server_flag = true
#   client_flag = false
#   max_ttl = 3600
#   ttl = 1800
#   key_type = "ec"
#   key_bits = 256

#   key_usage = [
#     "DigitalSignature",
#     "KeyAgreement",
#     "KeyEncipherment",
#   ]

#   no_store = true
# }