
resource "aws_amplify_app" "example" {
  name       = "amplify-vite-react-template"
  repository = "https://github.com/raisolanoorg/amplify-vite-react-template"
  access_token = var.my_link

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