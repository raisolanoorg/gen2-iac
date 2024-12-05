
module "policy_amplify_app_logs" {
  source = "github.com/raisolanoorg/iowatt-aws-iam-iac?ref=v0.0.1"

  create_policy      = true
  policy_name        = "amplify-gen2-policy"
  policy_description = "amplify-gen2-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:275675788467:log-group:/aws/amplify/*:log-stream:*"
      },
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:us-east-1:275675788467:log-group:/aws/amplify/*"
      },
      {
        Effect   = "Allow",
        Action   = "logs:DescribeLogGroups",
        Resource = "arn:aws:logs:us-east-1:275675788467:log-group:*"
      }
    ]
  })
}

module "amplify_opf_app_role" {
  source = "github.com/raisolanoorg/iowatt-aws-iam-iac?ref=v0.0.1"

  create_role       = true
  role_requires_mfa = false
  role_name         = "amplify-gen2-role"
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmplifyBackendDeployFullAccess",
    module.policy_amplify_app_logs.policy_arn
  ]
  data_trusted_role_arns     = []
  data_trusted_role_services = ["amplify.amazonaws.com"]
}



resource "aws_amplify_app" "example" {
  name                 = "amplify-vite-react-template"
  iam_service_role_arn = module.amplify_opf_app_role.this_iam_role_arn
  repository           = "https://github.com/raisolanoorg/amplify-vite-react-template"
  access_token         = var.my_link

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 1
    backend:
    phases:
        build:
        commands:
            - npm ci --cache .npm --prefer-offline
            - npx ampx pipeline-deploy --branch $AWS_BRANCH --app-id $AWS_APP_ID
    frontend:
    phases:
        build:
        commands:
            - npm run build
    artifacts:
        baseDirectory: dist
        files:
        - '**/*'
    cache:
        paths:
        - .npm/**/*
        - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    ENV = "prd"
  }
}