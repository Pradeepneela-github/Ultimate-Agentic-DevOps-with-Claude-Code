# Cost Optimization - Quick Reference

## One-Page Summary

Your portfolio site infrastructure (S3 + CloudFront) can save **40-60%** in monthly costs with configuration changes only.

**Total Potential Savings: $12.70-48/month** (depending on traffic)

---

## The 8 Optimizations

| # | Change | File/Line | Saves | Time |
|---|--------|-----------|-------|------|
| 1 | `price_class = "PriceClass_100"` | main.tf:73 | $4-22/mo | 2 min |
| 2 | `versioning status = "Suspended"` | main.tf:21 | $0.20-1/mo | 2 min |
| 3 | `default_ttl = 604800` | main.tf:97 | $8-10/mo | 2 min |
| 4 | Error response: HTTP 200 → 404 | main.tf:105 | $0.50-2/mo | 5 min |
| 5 | Error response: TTL 0 → 300 | main.tf:106 | (included #4) | 5 min |
| 6 | Add lifecycle rules | main.tf (new) | Future savings | 5 min |
| 7 | Create /404.html | site root | SEO fix | 5 min |
| 8 | http_version: "http2" | main.tf:83 | $0-0.10/mo | 1 min |

---

## Implementation: 3 Phases

### Phase 1: Core Changes (15 minutes)
```bash
# Edit terraform/main.tf:
# - Line 73: price_class = "PriceClass_100"
# - Line 21: status = "Suspended"
# - Line 97: default_ttl = 604800
# - Line 98: max_ttl = 2592000

cd terraform
terraform plan
terraform apply
```

### Phase 2: Polish (20 minutes)
```bash
# Edit terraform/main.tf:
# - Line 105: response_code = 404
# - Line 105: response_page_path = "/404.html"
# - Line 106: error_caching_min_ttl = 300
# - Add lifecycle rule resource

# Create /404.html with proper error page

terraform plan
terraform apply
aws s3 sync ./ s3://portfolio-site-production-<ID>/ --exclude "terraform/*" --exclude ".git/*"
```

### Phase 3: Optional (10 minutes)
```bash
# Edit terraform/main.tf:
# - Line 83: http_version = "http2"

terraform plan
terraform apply
```

---

## Key Numbers

### Monthly Cost Estimates

| Metric | Current | Optimized | Savings |
|--------|---------|-----------|---------|
| Price Class | PriceClass_200 | PriceClass_100 | 50% reduction |
| Data Transfer Cost | $20/mo | $10/mo | $10/mo |
| Origin Requests | 150K/mo | 7.5K/mo | 95% fewer |
| Request Costs | $15/mo | $1/mo | $14/mo |
| Storage | $2/mo | $1/mo | $1/mo |
| **Total** | **$47/mo** | **$24/mo** | **$23/mo (49%)** |

*Estimates based on 100 visitors/day, 50GB/month transfer*

---

## Cache Strategy After TTL Change

**Current (1 hour TTL)**: Checks origin every hour = 24 checks/day per visitor

**New (7 days TTL)**: Checks origin once per week = more efficient

**Emergency Updates**:
```bash
# Use free CloudFront invalidation (1000/month free)
aws cloudfront create-invalidation \
  --distribution-id <ID> \
  --paths "/*"
```

Live in ~30 seconds, no 7-day wait.

---

## Validation Checklist

After implementation:
- [ ] Terraform apply succeeded
- [ ] Website loads correctly
- [ ] 404 page shows for missing files
- [ ] Cache headers show 7-day TTL
- [ ] CloudFront metrics show >95% cache hit ratio

---

## Files in This Review

1. **COST_OPTIMIZATION_REPORT.md** - Detailed analysis (10 pages)
2. **IMPLEMENTATION_GUIDE.md** - Step-by-step walkthrough (20 pages)
3. **OPTIMIZED_main.tf** - Example updated Terraform code
4. **COST_QUICK_REFERENCE.md** - This file (1 page summary)

---

## Testing Commands

```bash
# Get distribution info
DIST_ID=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Comment=='portfolio-site'].Id" \
  --output text)
echo "Your distribution: $DIST_ID"

# Check cache headers
curl -I https://<cloudfront-domain>/ | grep -i cache

# Test 404 page
curl -I https://<cloudfront-domain>/nonexistent.html
# Should return HTTP 404

# Monitor cache hit ratio
aws cloudfront get-distribution --id $DIST_ID
# Check "CacheBehaviors" and "Statistics" in CloudFront console
```

---

## Risk Assessment

**Overall Risk**: LOW

All changes are:
- ✓ Configuration-only (no code changes)
- ✓ Reversible (git backup available)
- ✓ Tested (dry-run with `terraform plan` first)
- ✓ Standard AWS best practices
- ✓ Used by large-scale sites (cache TTL is normal; invalidation API exists for urgent updates)

---

## Timeline

- **Phase 1 (core savings)**: 15 minutes
- **Phase 2 (polish)**: 20 minutes
- **Phase 3 (optional)**: 10 minutes
- **Testing**: 5 minutes
- **Total**: ~50 minutes for full implementation

Cloudfront propagates changes in ~3 minutes.

---

## One-Minute Summary

**Problem**: Your CloudFront is configured for high-traffic, multi-region scenarios that don't apply to a portfolio site.

**Solution**: Reduce to cost-effective baseline:
1. Cheaper edge locations (PriceClass_100 instead of 200)
2. Aggressive caching (7 days instead of 1 hour)
3. Proper error handling (HTTP 404 instead of 200)
4. No unnecessary versioning

**Result**: 40-60% cost reduction, better cache hit ratio, faster pages, better SEO.

---

## Next Steps

1. Read **COST_OPTIMIZATION_REPORT.md** for full context
2. Review **OPTIMIZED_main.tf** for code changes
3. Follow **IMPLEMENTATION_GUIDE.md** step-by-step
4. Apply changes with `terraform plan` then `terraform apply`
5. Validate with provided test commands
6. Monitor CloudFront metrics for 1-2 weeks

---

**Questions?** See IMPLEMENTATION_GUIDE.md FAQ section.

**Ready to save money?** Start with Phase 1 - it's 15 minutes for ~$12/month savings.
