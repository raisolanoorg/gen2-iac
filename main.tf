resource "aws_iam_policy" "policy_amplify_app_logs" {
  name        = "amplify-gen2-policy"
  description = "amplify-gen2-policy"
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

resource "aws_iam_role" "amplify_app_role" {
  name               = "amplify-gen2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "amplify.amazonaws.com" # Cambia según quién asumirá el rol (ejemplo: Lambda sería "lambda.amazonaws.com")
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_1" {
  role       = aws_iam_role.amplify_app_role.name
  policy_arn = aws_iam_policy.policy_amplify_app_logs.arn
}

resource "aws_iam_role_policy_attachment" "attach_policy_2" {
  role       = aws_iam_role.amplify_app_role.name
  policy_arn =  "arn:aws:iam::aws:policy/service-role/AmplifyBackendDeployFullAccess"
}

resource "aws_amplify_app" "example" {
  name                 = "amplify-vite-react-template"
  iam_service_role_arn = aws_iam_role.amplify_app_role.arn
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

/*resource "aws_amplify_domain_association" "example" {
  app_id      = aws_amplify_app.example.id
  domain_name = "iowattqa.com"

  # https://www.example.com
  sub_domain {
    branch_name = "main"
    prefix      = "store"
  }

  certificate_settings {
    type = "CUSTOM"
    custom_certificate_arn = "arn:aws:acm:us-east-1:275675788467:certificate/6f040252-509a-497d-ad93-df6b0fb062f2"
  }
}*/