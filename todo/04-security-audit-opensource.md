# Task 04: Security Audit & Open Source Preparation

## Priority
**HIGH** - Required before public release

## Overview
Perform comprehensive security audit of the restim-mobile repository before open sourcing. Ensure no sensitive information, credentials, or internal infrastructure details are exposed.

---

## Part 1: Git History Analysis

### 1.1 Search Historical Commits for Secrets
Scan entire git history for accidentally committed sensitive files or data.

**Tasks:**
- [ ] Search git history for `.env` files that were later removed
- [ ] Search for any files containing patterns like:
  ```
  api_key=, apikey=, api-key=
  secret=, password=, token=
  Bearer, Authorization:
  sk-, pk-, AIza (OpenAI, Stripe, Google keys)
  ghp_, ghu_, github_pat_ (GitHub tokens)
  -----BEGIN.*PRIVATE KEY-----
  ```
- [ ] Use tools like `git-secrets`, `gitleaks`, or `trufflehog`
- [ ] Check for large files that might contain secrets

**Commands to run:**
```bash
# Check for secrets in entire history
git log --all --full-history --source -- "*.env*" "*secret*" "*key*" "*token*"

# Search for API key patterns in history
git log -p --all -S "api_key" -- "*.ts" "*.tsx" "*.js" "*.dart"

# Use gitleaks (if installed)
gitleaks detect --source . --verbose

# Use trufflehog (if installed)
trufflehog git file://. --only-verified
```

### 1.2 Clean Git History (if needed)
If secrets are found in history:

**Tasks:**
- [ ] Use `git filter-repo` or `BFG Repo-Cleaner` to remove secrets
- [ ] Force push to create clean history
- [ ] Rotate any compromised credentials immediately
- [ ] Document the cleanup process

---

## Part 2: Current Codebase Scan

### 2.1 Hardcoded Credentials Check
Scan all source files for hardcoded secrets.

**Files to check:**
- TypeScript/JavaScript: `src/**/*.ts`, `src/**/*.tsx`
- Dart: `restim-flutter/lib/**/*.dart`
- Configuration: `*.json`, `*.yaml`, `*.yml`
- Environment: `.env`, `.env.*`, `env.js`

**Patterns to search:**
```bash
# API keys and tokens
grep -r -i -n "api_key\|apikey\|api-key" --include="*.ts" --include="*.tsx" --include="*.dart" --exclude-dir=node_modules

# Passwords and secrets
grep -r -i -n "password.*=.*['\"]\|secret.*=.*['\"]" --include="*.ts" --include="*.tsx" --include="*.dart" --exclude-dir=node_modules

# Authorization headers with hardcoded values
grep -r -n "Bearer\s+['\"][A-Za-z0-9]" --include="*.ts" --include="*.tsx" --include="*.dart" --exclude-dir=node_modules

# Private keys
grep -r -n "BEGIN.*PRIVATE" --include="*.ts" --include="*.tsx" --include="*.dart" --exclude-dir=node_modules
```

**Tasks:**
- [ ] Run all pattern searches
- [ ] Review each match (many will be false positives like variable names)
- [ ] Remove or replace any actual secrets with environment variables
- [ ] Document any secrets found and remediation actions

### 2.2 IP Address and Infrastructure Exposure
Check for internal network information that shouldn't be public.

**Findings to review:**
- [ ] Internal IP addresses (192.168.x.x, 10.x.x.x, 172.16.x.x)
- [ ] Internal hostnames or domains
- [ ] VPN or internal service URLs
- [ ] Personal email addresses (replace with generic contact)

**Current findings (from initial scan):**
```
NETWORK_TROUBLESHOOTING.md:122:192.168.178.30  ← HERE
QUICK_START.md:62:192.168.178.30              ← HERE
src/store/deviceStore.ts:186:'192.168.1.1'    ← Default, probably OK
```

**Tasks:**
- [ ] Replace `192.168.178.30` with generic example IP (e.g., `192.168.1.100`)
- [ ] Update documentation with placeholders
- [ ] Verify no internal hostnames are mentioned
- [ ] Check for any personal information in commits (names, emails)

### 2.3 Dependency Vulnerability Scan
Check for known vulnerabilities in dependencies.

**Tasks:**
- [ ] Run `npm audit` (if Node.js project exists)
- [ ] Run `flutter pub outdated` to check for outdated Flutter packages
- [ ] Review each dependency for security advisories
- [ ] Update vulnerable packages
- [ ] Document any packages that can't be updated and why

**Commands:**
```bash
# Flutter dependencies
cd restim-flutter
flutter pub outdated
flutter pub upgrade --major-versions

# Check for known vulnerabilities (if using pub.dev)
# Manual review of pubspec.lock for version ranges
```

---

## Part 3: Configuration Files Review

### 3.1 .gitignore Completeness
Ensure `.gitignore` prevents accidental commits of sensitive files.

**Current `.gitignore`:**
```
source-repos/
.agent-instructions/
.claude/settings.local.json
**/bin/
**/obj/
*.user
*.suo
*.userosscache
*.sln.docstates
.vs/
```

**Missing entries to add:**
- [ ] `.env` and `.env.*`
- [ ] `*.secret`
- [ ] `*.pem`, `*.key`
- [ ] `credentials.json`
- [ ] `secrets.json`
- [ ] `.flutter-plugins-dependencies`
- [ ] `build/`, `.dart_tool/`, `.packages` (Flutter artifacts)
- [ ] `.expo/`, `dist/` (if using Expo)
- [ ] `*.apk`, `*.ipa` (build artifacts)
- [ ] `.DS_Store`, `Thumbs.db`

**Tasks:**
- [ ] Update `.gitignore` with comprehensive entries
- [ ] Document which files should contain secrets

### 3.2 Environment Variable Setup
Ensure proper use of environment variables for configuration.

**Tasks:**
- [ ] Create `.env.example` with template variables (no actual values)
- [ ] Document environment variables in README
- [ ] Ensure no `.env` files are committed
- [ ] Use secure storage for sensitive data in the app (e.g., flutter_secure_storage)

**Example `.env.example`:**
```bash
# API Keys (replace with your actual values)
# API_KEY=your_api_key_here

# WebDAV Configuration (optional)
# WEBDAV_URL=https://your-server.com/webdav
# WEBDAV_USERNAME=your_username
# WEBDAV_PASSWORD=your_password

# Device Configuration
# DEFAULT_DEVICE_IP=192.168.1.100
```

---

## Part 4: Documentation Sanitization

### 4.1 README.md Review
Ensure README contains no sensitive information.

**Tasks:**
- [ ] Remove any internal URLs or IPs
- [ ] Use generic email addresses (e.g., `contact@example.com`)
- [ ] Remove any personal information
- [ ] Add security disclosure policy
- [ ] Add contributing guidelines
- [ ] Add license file (if not present)

### 4.2 Documentation Files Review
Check all documentation files for sensitive info.

**Files to review:**
- [ ] `NETWORK_TROUBLESHOOTING.md` - Contains internal IP
- [ ] `QUICK_START.md` - Contains internal IP
- [ ] `MEDIA_SYNC_USAGE.md`
- [ ] `documents/**/*`
- [ ] `DONE.md`
- [ ] `TODO.md`

**Tasks:**
- [ ] Replace internal IPs with examples
- [ ] Remove any personal email addresses
- [ ] Remove any internal service names
- [ ] Update screenshots if they contain sensitive info

---

## Part 5: License and Legal

### 5.1 Choose Open Source License
**Tasks:**
- [ ] Select appropriate license (MIT, Apache 2.0, GPL, etc.)
- [ ] Create `LICENSE` file
- [ ] Add license header to source files (if required by license)
- [ ] Update `README.md` with license information
- [ ] Check dependencies for license compatibility

### 5.2 Third-Party Attribution
**Tasks:**
- [ ] List all third-party libraries and their licenses
- [ ] Create `THIRD_PARTY_LICENSES` file or section in README
- [ ] Ensure compliance with all dependency licenses
- [ ] Check for any copyleft licenses that might affect the project

---

## Part 6: Repository Settings

### 6.1 GitHub Repository Configuration
Before making the repo public:

**Tasks:**
- [ ] Enable branch protection for `master`/`main`
- [ ] Enable security alerts (Dependabot)
- [ ] Enable secret scanning
- [ ] Enable vulnerability alerts
- [ ] Review existing issues/discussions for sensitive info
- [ ] Remove any GitHub Actions secrets that are no longer needed
- [ ] Set up SECURITY.md with responsible disclosure policy

### 6.2 GitHub Actions (if any)
**Tasks:**
- [ ] Review all workflow files for secrets
- [ ] Ensure secrets are stored in GitHub Secrets, not in files
- [ ] Check workflow logs for accidentally printed secrets
- [ ] Update workflows to mask sensitive output

---

## Part 7: Pre-Publication Checklist

### 7.1 Final Review
Before making repository public:

- [ ] All above tasks completed
- [ ] Git history confirmed clean
- [ ] No secrets in current codebase
- [ ] Documentation sanitized
- [ ] License file added
- [ ] Security policy added
- [ ] `.gitignore` comprehensive
- [ ] `.env.example` created (if needed)
- [ ] README updated with public-ready content
- [ ] All contributors agree to publication
- [ ] Organization owner approval (if applicable)

### 7.2 Post-Publication
After making repository public:

- [ ] Enable all GitHub security features
- [ ] Monitor for security issues
- [ ] Set up dependabot updates
- [ ] Document security update process
- [ ] Create issue template for security vulnerabilities

---

## Tools to Use

### Automated Scanning Tools
```bash
# GitLeaks - scan for secrets
# Install: https://github.com/gitleaks/gitleaks
gitleaks detect --source . --verbose --report-path gitleaks-report.json

# TruffleHog - search git history for secrets
# Install: https://github.com/trufflesecurity/trufflehog
trufflehog git file://. --only-verified --json

# Git-secrets - prevent future commits with secrets
# Install: https://github.com/awslabs/git-secrets
git secrets --install
git secrets --register-aws

# Node.js audit (if applicable)
npm audit

# Flutter dependencies
cd restim-flutter
flutter pub outdated
```

### Manual Review Checklist
- [ ] Search for all patterns listed above
- [ ] Review each file in root directory
- [ ] Review all configuration files
- [ ] Review all documentation files
- [ ] Spot-check source files in each directory
- [ ] Review git log for any concerning commits

---

## Current Known Issues

### Issue 1: Internal IP Address in Documentation
**Files affected:**
- `NETWORK_TROUBLESHOOTING.md` (line 122, 132, 150, 153, 159)
- `QUICK_START.md` (line 62, 69, 70, 95)

**Current value:** `192.168.178.30`
**Action:** Replace with `192.168.1.100` or `YOUR_DEVICE_IP`

### Issue 2: Default Device IP in Store
**File:** `src/store/deviceStore.ts` (line 186)
**Current value:** `'192.168.1.1'`
**Assessment:** Generic default, probably OK
**Action:** Verify no security risk, consider `127.0.0.1` or empty string

### Issue 3: Email Address in Git
**Value:** `goran.obradovic@gmail.com`
**Action:** Consider using noreply email or generic contact for public repo

---

## Deliverables

1. **Security Audit Report**
   - Summary of all findings
   - Risk assessment for each issue
   - Remediation actions taken
   - Residual risks (if any)

2. **Clean Git History**
   - Evidence of secret scanning
   - Git history cleaning (if performed)
   - Confirmation of clean state

3. **Updated Documentation**
   - Sanitized README
   - Sanitized all documentation files
   - .env.example (if needed)
   - SECURITY.md

4. **License File**
   - Chosen license
   - Third-party attributions
   - License compatibility check

5. **Pre-Publication Checklist**
   - All items checked off
   - Sign-off from project owner

---

## Acceptance Criteria

- [ ] No secrets in git history (verified with tools)
- [ ] No secrets in current codebase (verified with tools)
- [ ] No internal IPs or hostnames in documentation
- [ ] No personal email addresses exposed
- [ ] .gitignore comprehensive and complete
- [ ] LICENSE file added
- [ ] SECURITY.md added
- [ ] All dependencies scanned for vulnerabilities
- [ ] GitHub security features enabled
- [ ] Documentation ready for public consumption
- [ ] All contributors notified of publication
