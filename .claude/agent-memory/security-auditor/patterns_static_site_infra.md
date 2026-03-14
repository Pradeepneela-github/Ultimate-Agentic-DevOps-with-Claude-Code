---
name: static_site_terraform_patterns
description: Recurring security anti-patterns found in static site Terraform deployments (S3 + CloudFront)
type: reference
---

# Recurring Patterns in Static Site Terraform Security Audits

## Always Check
- tfstate and tfstate.backup committed to git — most common critical finding; always grep `.gitignore` for `*.tfstate`; absence of .gitignore entirely is also a finding
- CloudFront `minimum_protocol_version` — defaults to TLSv1 when using cloudfront_default_certificate; must be set explicitly to TLSv1.2_2021
- CloudFront `logging_config` — frequently omitted on static sites
- CloudFront `response_headers_policy_id` — security headers almost always missing on first-pass infra
- CloudFront `web_acl_id` — WAF rarely attached on personal/portfolio projects
- CloudFront `allowed_methods` — developers copy full REST method list for static sites; only GET/HEAD/OPTIONS needed
- S3 `aws_s3_bucket_server_side_encryption_configuration` — AWS default AES256 does not mean it is Terraform-managed
- S3 `logging` — almost always empty on first-pass infra
- Remote backend commented out — local state is common in learning/DMI environments
- `compress = false` — gzip/brotli disabled by default on forwarded_values style cache behaviors
- Cost-optimization alternate files (e.g., OPTIMIZED_main.tf) — these often introduce security regressions (suspended versioning, dropped encryption, no security headers) that must be audited separately

## Positive Patterns Seen
- OAC (not OAI) correctly used
- All four public access block settings set to true
- `viewer_protocol_policy = "redirect-to-https"` set
- S3 bucket policy scoped to specific CloudFront distribution ARN via SourceArn condition
- S3 versioning enabled (main.tf only — suspended in OPTIMIZED_main.tf)
- provider default_tags configured
- No hardcoded credentials in .tf files
- aws_s3_bucket_server_side_encryption_configuration added in third audit cycle (AES256 + bucket_key_enabled)

## State File Exposure Pattern
When tfstate is committed, the following fields are typically exposed:
- `account_id` and `id` in aws_caller_identity data source
- `arn` for IAM user (reveals username)
- `user_id` (IAM access key prefix)
- Full ARNs for every resource including distribution IDs, OAC IDs, bucket ARNs
Remediation requires both .gitignore addition AND git history rewrite (git filter-repo or BFG).
