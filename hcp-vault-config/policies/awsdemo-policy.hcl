path "aws/creds/deploy_ec2"
{
  capabilities = ["read", "list"]
}

path "aws/creds/deploy_s3"
{
  capabilities = ["read", "list"]
}

path "auth/token/create"
{
    capabilities = ["create", "read", "update", "delete", "list"]
}