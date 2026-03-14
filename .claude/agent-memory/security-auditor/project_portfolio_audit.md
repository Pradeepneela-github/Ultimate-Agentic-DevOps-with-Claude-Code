---
name: portfolio_site_audit
description: Security audit results for the portfolio-site Terraform infrastructure — S3 + CloudFront static site deployment
type: project
---

# Portfolio Site Terraform Audit (last run: 2026-03-13, third audit)

## Infrastructure Summary
- AWS Account ID: 872450837433 (EXPOSED in state file — unresolved)
- IAM User: PraDevOps-cli (EXPOSED in state file — unresolved)
- IAM User ID: AIDA4WIQ7JO4R4SYOTLZK (EXPOSED in state file — unresolved)
- Region: ap-south-1
- S3 bucket: portfolio-site-production-872450837433
- CloudFront distribution: E2PNVYV3ZZYLOQ / d2oj4zoyfejgp9.cloudfront.net
- OAC ID: EPYP8LQTX3ZVK

## What Changed Since Last Audit (2026-03-13 run #2)

### Improvement: S3 encryption now Terraform-managed (HIGH #3 remediated)
- `aws_s3_bucket_server_side_encryption_configuration` resource added to main.tf with AES256 and bucket_key_enabled = true
- State confirms encryption is applied

### No Other Remediations
All other previously reported findings remain open as of this run.

### New file introduced: OPTIMIZED_main.tf (root, untracked)
This file was introduced as a cost-optimization alternative and introduces **new security regressions**:
- S3 versioning suspended (weakens recovery posture)
- allowed_methods still full REST list (same as main.tf)
- viewer_certificate still uses cloudfront_default_certificate with no minimum_protocol_version (same TLSv1 exposure)
- No response_headers_policy_id, no logging_config, no web_acl_id
- No aws_s3_bucket_server_side_encryption_configuration resource (regression — removes encryption that main.tf now has)

## Open Findings

### CRITICAL
1. terraform.tfstate committed to version control — contains AWS account ID (872450837433), IAM user ARN (arn:aws:iam::872450837433:user/PraDevOps-cli), IAM user_id (AIDA4WIQ7JO4R4SYOTLZK), CloudFront distribution ID (E2PNVYV3ZZYLOQ), OAC ID (EPYP8LQTX3ZVK), S3 bucket ARN. Must be removed from git history and added to .gitignore.
2. terraform.tfstate.backup also committed — same exposure as above.
3. No .gitignore exists in the repository root — nothing prevents future state files, secrets, or provider binaries from being committed.

### HIGH
4. TLS minimum protocol version is TLSv1 — CloudFront viewer_certificate uses cloudfront_default_certificate with no minimum_protocol_version override; state confirms TLSv1. Must be TLSv1.2_2021.
5. No CloudFront access logging configured — logging_config block absent; confirmed empty in state.
6. No S3 server access logging configured — logging block empty in state.
7. No AWS WAF attached to CloudFront distribution — web_acl_id empty in state.
8. No CloudFront response headers policy — response_headers_policy_id empty in state; no CSP, X-Frame-Options, HSTS, X-Content-Type-Options, Referrer-Policy.

### MEDIUM
9. CloudFront allowed_methods includes DELETE, PATCH, POST, PUT — static site needs only ["GET", "HEAD", "OPTIONS"].
10. No S3 lifecycle policy — versioning enabled but no lifecycle rule; non-current versions accumulate indefinitely.
11. Remote state backend commented out in backend.tf — state stored locally; no encryption at rest for state, no DynamoDB locking.
12. compress = false on default_cache_behavior — Gzip/Brotli compression disabled.
13. No Owner tag on resources — provider default_tags only has Project, Environment, ManagedBy.

### LOW
14. error_caching_min_ttl = 0 for 404 custom error response — every 404 re-hits origin.
15. No description/comment on CloudFront distribution resource.

## Remediated Findings
- Finding #3 from 2026-03-13 run #2: S3 encryption now explicitly managed via aws_s3_bucket_server_side_encryption_configuration (AES256, bucket_key_enabled = true).
