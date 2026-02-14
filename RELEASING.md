# Release Process

This document describes how to create a new release of Alesqui Intelligence.

## Automated Release (Recommended)

Releases are automated via GitHub Actions. Simply create and push a version tag:

```bash
# 1. Ensure you're on main branch with latest changes
git checkout main
git pull origin main

# 2. Create a version tag (use semantic versioning)
git tag -a v1.0.0 -m "Release version 1.0.0"

# 3. Push the tag to GitHub
git push origin v1.0.0
```

The GitHub Actions workflow will automatically:
- ✅ Package the distribution files
- ✅ Generate release notes from commits
- ✅ Create a GitHub Release
- ✅ Upload the `.tar.gz` package
- ✅ Generate checksums

## Semantic Versioning

We follow [Semantic Versioning](https://semver.org/):

- **Major version** (v2.0.0): Breaking changes
- **Minor version** (v1.1.0): New features, backwards compatible
- **Patch version** (v1.0.1): Bug fixes, backwards compatible

## Manual Release (Emergency)

If GitHub Actions is unavailable:

```bash
# 1. Package the distribution
./scripts/package.sh v1.0.0

# 2. Create release manually on GitHub
# - Go to: https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/releases/new
# - Tag: v1.0.0
# - Title: Alesqui Intelligence v1.0.0
# - Upload: dist/alesqui-intelligence-v1.0.0.tar.gz
# - Upload: dist/checksums.txt
```

## Testing Before Release

Always test the package before creating a release:

```bash
# Create test package
./scripts/package.sh test-$(date +%Y%m%d)

# Test installation
mkdir -p /tmp/test-install
tar -xzf dist/alesqui-intelligence-test-*.tar.gz -C /tmp/test-install
cd /tmp/test-install/alesqui-intelligence
./install.sh
```

## Release Checklist

Before creating a release:

- [ ] All tests pass
- [ ] Documentation is up to date
- [ ] CHANGELOG.md is updated
- [ ] Version number follows semantic versioning
- [ ] No uncommitted changes
- [ ] On main branch
- [ ] All PRs merged
- [ ] Docker images are built and tested
- [ ] Installation tested on clean system

## Hotfix Releases

For urgent bug fixes:

```bash
# Create hotfix branch from tag
git checkout -b hotfix/1.0.1 v1.0.0

# Make fixes and commit
git commit -am "Fix critical bug"

# Create and push tag
git tag -a v1.0.1 -m "Hotfix release 1.0.1"
git push origin v1.0.1

# Merge back to main
git checkout main
git merge hotfix/1.0.1
git push origin main
```

## Release Announcement

After release is published:

1. Update website download link
2. Announce on social media/blog
3. Send email to beta users
4. Update documentation site
