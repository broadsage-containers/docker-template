# 🐳 Container Update

## 📦 Container Details

- **Container Name**: <!-- e.g., nginx, redis, postgres -->
- **Current Version**: <!-- e.g., 1.28.0 (if updating) -->
- **New Version**: <!-- e.g., 1.29.0 -->
- **Base Image**: <!-- e.g., debian:12-slim, alpine:3.18 -->

## 🔧 Type of Change

- [ ] 🆕 New container image
- [ ] ⬆️ Version update
- [ ] 🔒 Security patch
- [ ] 🐛 Bug fix
- [ ] ⚙️ Configuration change

## 📝 What Changed

<!-- Describe the main changes -->

### Upstream Changes (if version update)

- Upstream Release: <!-- link -->
- Security Advisory: <!-- link if applicable -->
- Notable Changes: <!-- key highlights -->

## 🧪 Testing

- [ ] ✅ Container builds successfully
- [ ] ✅ Container starts and runs correctly
- [ ] ✅ Basic functionality works as expected
- [ ] ✅ Security scan passes (no critical vulnerabilities)
- [ ] ✅ Multi-architecture build tested (if applicable)

**Test commands used:**

```bash
# Add the specific commands you used to test
make build CONTAINER=your-container
make test CONTAINER=your-container
# docker run -d your-container:tag
```

## 💥 Breaking Changes

- [ ] ❌ No breaking changes
- [ ] ⚠️ Breaking changes (describe below)

<!-- If breaking changes, explain what users need to do -->

## 🚀 Usage Example

```bash
# How to use this container
docker run -d --name my-app your-container:version
```

## 📊 Image Metrics

- **Image Size**: <!-- e.g., 150 MB -->
- **Size Change**: <!-- +/- XX MB from previous version -->
- **Security Scan**: <!-- Clean / X vulnerabilities fixed -->

## 🔗 Related Issues

- Closes #<!-- issue number -->
- Related to #<!-- issue number -->

## 📝 Additional Notes

<!-- Any other context for reviewers -->
