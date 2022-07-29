resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("policies/admin-policy.hcl")
}

resource "vault_policy" "orcha_r_policy" {
  name   = "orcha_r_policy"
  policy = file("policies/orcha-r-policy.hcl")
}

resource "vault_policy" "consul-policy" {
  name   = "consul-policy"
  policy = file("policies/consul-policy.hcl")
}

resource "vault_policy" "awsdemo" {
  name   = "awsdemo-policy"
  policy = file("policies/awsdemo-policy.hcl")
}