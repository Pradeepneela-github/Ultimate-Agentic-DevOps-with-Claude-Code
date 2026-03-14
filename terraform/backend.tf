# IMPORTANT: Remote state backend configuration
#
# To use a remote S3 backend instead of local state:
#
# 1. First run: `terraform init` (without backend to use local state)
# 2. Create the infrastructure: `terraform apply`
# 3. Create an S3 bucket for Terraform state (e.g., portfolio-site-terraform-state)
# 4. Uncomment the backend block below
# 5. Run: `terraform init -migrate-state` to move local state to S3
#
# This approach avoids chicken-egg problem where you need state to manage the state bucket.

# terraform {
#   backend "s3" {
#     bucket         = "portfolio-site-terraform-state"
#     key            = "production/terraform.tfstate"
#     region         = "ap-south-1"
#     encrypt        = true
#     dynamodb_table = "terraform-lock"
#   }
# }
