🔐 Required GitHub Secrets
Add these secrets in your GitHub repository settings (Settings > Secrets and variables > Actions):
AWS Secrets
AWS_ACCESS_KEY_ID_DEV
AWS_SECRET_ACCESS_KEY_DEV
AWS_ACCESS_KEY_ID_PROD
AWS_SECRET_ACCESS_KEY_PROD
Snowflake Secrets
SNOWFLAKE_ACCOUNT
SNOWFLAKE_USER_DEV
SNOWFLAKE_PASSWORD_DEV
SNOWFLAKE_USER_PROD
SNOWFLAKE_PASSWORD_PROD
SNOWFLAKE_CI_USER
SNOWFLAKE_CI_PASSWORD
Optional
SLACK_WEBHOOK (for notifications)

📖 Usage Instructions
Running CI Pipeline
bash# Automatically runs on push/PR to main or develop
git push origin develop
Running Terraform Plan
bash# Automatically runs on PR with terraform changes
# Or manually:
gh workflow run terraform-plan.yml -f environment=dev
Manual Terraform Apply
bash# Through GitHub UI with manual approval
# Or via CLI:
gh workflow run terraform-plan.yml -f environment=prod
Building Docker Images
bash# Automatically runs on push to main
# Or manually:
gh workflow run docker-build.yml
