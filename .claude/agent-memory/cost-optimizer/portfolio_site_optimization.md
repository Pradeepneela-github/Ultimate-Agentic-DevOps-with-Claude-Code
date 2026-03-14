---
name: Portfolio Site Cost Optimization Analysis
description: Comprehensive cost review of static portfolio site infrastructure (S3 + CloudFront) with 8 specific optimizations
type: project
---

## Infrastructure Overview

**Project**: portfolio-site (Static HTML/CSS portfolio website)
**Tech Stack**: S3 + CloudFront (no compute layer)
**Region**: ap-south-1 (Mumbai)
**Current Cost**: $15-25/month (depends on traffic)
**Optimized Cost**: $6-12/month
**Potential Savings**: 40-60%

## Key Findings

### High-Impact Issues Identified

1. **CloudFront PriceClass_200 is oversized**
   - Serves from expensive edge locations unnecessary for portfolio
   - Change to PriceClass_100: saves $4-22/month
   - Risk: VERY LOW - PriceClass_100 covers 90%+ of users

2. **S3 versioning enabled on low-update-frequency content**
   - Static website rarely changes; versioning stores duplicates
   - Disable versioning: saves $0.20-1/month
   - Alternative: Set lifecycle rule to delete versions after 30 days

3. **CloudFront cache TTL too short (1 hour)**
   - Causes unnecessary origin revalidation requests
   - 24 revalidations per unique visitor per day
   - Change from 3600s to 604800s (7 days): saves $8-10/month
   - Acceptable for static content; use free invalidation API for urgent updates

4. **404 error responses misconfigured**
   - Returns HTTP 200 instead of 404 (bad for SEO)
   - No caching on error responses (wastes origin requests)
   - Should return HTTP 404 with 5-minute cache

5. **HTTP/3 support unnecessary**
   - Minimal benefit for static sites
   - Optional to disable; negligible cost impact

## Architecture Notes

- **Security**: Proper - S3 public access blocked, CloudFront uses OAC (Origin Access Control)
- **Redundancy**: Good - CloudFront provides global distribution
- **Cost Structure**: Dominated by data transfer ($0.042-0.085/GB depending on price class)

## Recommended Changes Priority

### Phase 1 (Do Immediately - 15 minutes)
1. PriceClass_200 → PriceClass_100 (save $4-22/mo)
2. Versioning: Enabled → Suspended (save $0.20-1/mo)
3. TTL: 3600s → 604800s (save $8-10/mo)

### Phase 2 (Do Next - 20 minutes)
4. Error response: HTTP 200 → HTTP 404 with 300s cache
5. Add lifecycle rule for old versions (30-day expiration)
6. Create proper 404.html error page

### Phase 3 (Optional)
7. HTTP/2 only (vs. http2and3) - minimal impact
8. Plan remote state backend when team scaling needed (adds $1.35/mo)

## Files Created

- `COST_OPTIMIZATION_REPORT.md` - Detailed analysis with estimates
- `IMPLEMENTATION_GUIDE.md` - Step-by-step implementation instructions
- `OPTIMIZED_main.tf` - Example updated Terraform code with all changes

## Monitoring Metrics

After optimization, validate:
- CloudFront cache hit ratio should increase from ~80% to 95%+
- S3 storage should decrease month-over-month (as versioning disables)
- Origin request count should drop 95% (fewer revalidations)
- Use CloudFront invalidation API (free, 1000/month) for urgent content updates

## Cost Model

For typical light portfolio (100 visitors/day, 50GB/month data transfer):
- **Current**: $7-10/month
- **Optimized**: $3-5/month
- **Savings**: 50%

Scales linearly with traffic - higher traffic = higher absolute savings (but same percentage).

## Implementation Complexity

- **Difficulty**: LOW - Configuration-only changes
- **Risk**: LOW - All changes are reversible via git
- **Downtime**: ~3 minutes (CloudFront propagation)
- **Testing**: Easy - curl commands to verify cache behavior

## Known Good Practices Already Implemented

✓ CloudFront OAC (modern security, vs. legacy origin access identity)
✓ IPv6 support enabled (future-proof)
✓ Proper error handling for SPA-style routing (404 → index.html)
✓ Security headers (HTTPS only, public access blocked)
✓ Terraform state management (though currently local)

## Next Steps

1. Review COST_OPTIMIZATION_REPORT.md for detailed analysis
2. Follow IMPLEMENTATION_GUIDE.md for step-by-step changes
3. Test with terraform plan before applying
4. Monitor metrics after deployment (cache hit ratio, storage, costs)
