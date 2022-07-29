resource "vault_aws_secret_backend_role" "ec2" {
  backend = vault_aws_secret_backend.aws.path
  name    = "deploy_ec2"
  credential_type = "iam_user"

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action":["ec2:*","iam:GetUser"],
      "Resource": "*"
    }
  ]
}
EOT
}

resource "vault_aws_secret_backend_role" "s3" {
  backend = vault_aws_secret_backend.aws.path
  name    = "deploy_s3"
  credential_type = "iam_user"

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*","iam:GetUser"],
      "Resource": "*"
    }
  ]
}
EOT
}