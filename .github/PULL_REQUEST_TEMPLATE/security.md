# 🔒 Security Update

## 🚨 Security Issue Summary

**Brief Description:**
<!-- Concise description of the security issue being addressed -->

**Affected Components:**
<!-- List containers, versions, or components affected -->

## 🔧 Type of Security Change

- [ ] 🔴 Critical vulnerability fix (CVSS 9.0+)
- [ ] 🟠 High vulnerability fix (CVSS 7.0-8.9)
- [ ] 🟡 Medium/Low vulnerability fix (CVSS < 7.0)
- [ ] 🛡️ Security improvement/hardening
- [ ] 📦 Dependency security update

## 📋 Vulnerability Details

- **CVE ID**: <!-- e.g., CVE-2024-1234 -->
- **CVSS Score**: <!-- e.g., 8.5 (High) -->
- **Affected Containers**: <!-- e.g., nginx, all containers -->
- **Component**: <!-- e.g., OpenSSL 1.1.1 -->

## 🔧 What Changed

<!-- List the specific security changes -->

## 🧪 Security Testing

- [ ] ✅ Security scan shows vulnerability is fixed
- [ ] ✅ Container builds and runs normally
- [ ] ✅ No new security issues introduced
- [ ] ✅ Functionality still works correctly

**Security test commands:**

```bash
# Add security testing commands you used
make security-scan CONTAINER=your-container
# trivy image your-container:tag
```

## ⚡ Deployment Urgency

- [ ] 🔴 Critical - needs immediate deployment
- [ ] 🟠 High - should deploy within 24 hours
- [ ] 🟡 Medium - can wait for next release
- [ ] 🟢 Low - routine security maintenance

## 🔗 Related Issues

- Closes #<!-- issue number -->
- Related to #<!-- issue number -->

## 📝 Additional Notes

<!-- Any other context for reviewers -->
