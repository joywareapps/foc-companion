# Task 05: Android App Distribution Research

## Priority
**MEDIUM** - Required for beta testing and public release

## Overview
Research all publishing options for Android apps beyond Google Play Store, with focus on:
1. Quick beta distribution to testers
2. Easy installation process for non-technical users
3. Automated distribution via GitHub Actions or local builds
4. Cost, requirements, and limitations

---

## Requirements

### Primary Goals
- **Fast beta distribution** - Get app to testers within minutes/hours, not days
- **Easy installation** - Minimal friction for testers (ideally one-click install)
- **Automation-friendly** - Can be triggered from GitHub Actions or CLI
- **No app review delays** - Skip or minimize approval wait times

### Secondary Goals
- Low cost or free tier
- Analytics and crash reporting
- Update notifications
- Version management
- Feedback collection

---

## Part 1: Distribution Platforms Research

### 1.1 Open Source / Alternative App Stores

#### F-Droid
**Website:** https://f-droid.org

**Pros:**
- Free and open source focused
- No registration required for users
- Built-in update mechanism
- Strong privacy focus
- Can host your own repository

**Cons:**
- Requires app to be open source (source code must be published)
- Manual review process (can take weeks)
- No proprietary dependencies allowed
- Small user base compared to Play Store
- No beta/alpha channels

**Automation:**
- Can automate via `fdroidserver` CLI tools
- Requires setting up your own repo for faster updates
- GitHub Actions: Possible with custom workflow

**Quick Beta Capability:** ⚠️ SLOW (requires review)
**Best For:** Production releases of fully open-source apps

**Setup Requirements:**
- Source code must be publicly available
- Build must be reproducible
- No proprietary dependencies
- License must be OSI-approved

---

#### IzzyOnDroid
**Website:** https://apt.izzysoft.de/fdroid/

**Pros:**
- Faster than main F-Droid repo (days instead of weeks)
- Allows some proprietary dependencies
- Large user base (F-Droid compatible)
- Active maintainer

**Cons:**
- Still requires review
- Manual submission process
- Not ideal for rapid beta cycles
- Must meet quality standards

**Quick Beta Capability:** ⚠️ MODERATE (faster than F-Droid, still reviewed)
**Best For:** Production releases with some proprietary deps

---

#### Amazon Appstore
**Website:** https://developer.amazon.com/appservices

**Pros:**
- Pre-installed on Amazon devices (Fire tablets, Fire TV)
- Established marketplace
- Developer console with analytics
- Can distribute beta versions

**Cons:**
- Requires Amazon developer account ($0 but registration required)
- App review process (faster than Play Store but still exists)
- Smaller user base than Play Store
- Less automation-friendly

**Quick Beta Capability:** ⚠️ MODERATE (beta program exists but requires setup)
**Best For:** Reaching Amazon device users

---

#### Samsung Galaxy Store
**Website:** https://developer.samsung.com/galaxy-store

**Pros:**
- Pre-installed on Samsung devices (large market)
- Samsung-specific features and promotions
- Established marketplace

**Cons:**
- Requires Samsung seller account
- App review process
- Samsung devices only
- Less automation-friendly

**Quick Beta Capability:** ⚠️ MODERATE
**Best For:** Reaching Samsung device users specifically

---

### 1.2 Beta Distribution Platforms

#### Firebase App Distribution (Recommended for Beta)
**Website:** https://firebase.google.com/products/app-distribution

**Pros:**
- ✅ **Fast distribution** - Upload and testers get it immediately
- ✅ **No app review** - Direct distribution to invited testers
- ✅ **Easy tester management** - Email invitations, groups
- ✅ **Automation-friendly** - CLI tools, Fastlane, GitHub Actions
- ✅ **Cross-platform** - iOS and Android from same console
- ✅ **Analytics integration** - Crashlytics, Analytics, Performance
- ✅ **Free tier** - Generous limits for small apps
- ✅ **Update notifications** - Testers get notified of new builds

**Cons:**
- Google account required for testers
- Requires Firebase project setup
- Testers need to install Firebase profile (one-time)
- Not a public app store (testers only)

**Automation:**
- CLI: `firebase appdistribution:distribute`
- Fastlane: `firebase_app_distribution` plugin
- GitHub Actions: Official Firebase GitHub Action available
- Local build + upload: ✅ YES

**Quick Beta Capability:** ✅ EXCELLENT (immediate distribution)
**Best For:** Beta testing, internal distribution, rapid iteration

**GitHub Actions Example:**
```yaml
- name: Upload to Firebase App Distribution
  uses: wzieba/Firebase-Distribution-Github-Action@v1
  with:
    appId: ${{ secrets.FIREBASE_APP_ID }}
    serviceCredentialsFileContent: ${{ secrets.FIREBASE_CREDENTIALS }}
    groups: testers
    file: app/build/outputs/apk/release/app-release.apk
```

**Local CLI Example:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Distribute APK
firebase appdistribution:distribute app-release.apk \
  --app YOUR_APP_ID \
  --groups testers \
  --release-notes "Beta v1.2.0 - New pattern system"
```

---

#### TestFairy
**Website:** https://www.testfairy.com

**Pros:**
- ✅ Fast distribution (immediate)
- ✅ No app review
- ✅ Session recording and analytics
- ✅ Crash reporting
- ✅ Tester feedback in-app
- ✅ Automation via API and plugins
- ✅ Cross-platform (iOS, Android)

**Cons:**
- ⚠️ **Paid plans** - Free tier limited (500 MB storage, 2 apps)
- Requires TestFairy account for testers
- Proprietary SDK adds to app size
- Privacy concerns (session recording)

**Automation:**
- API: REST API for upload
- Fastlane: `testfairy` plugin
- GitHub Actions: Custom script with API
- Local build + upload: ✅ YES (via API)

**Quick Beta Capability:** ✅ EXCELLENT
**Best For:** Teams wanting detailed testing analytics

**Pricing:**
- Free: 2 apps, 500 MB storage
- Pro: $49/month per developer
- Enterprise: Custom pricing

---

#### TestFlight (iOS Only - Not Applicable)
Note: TestFlight is iOS-only, not relevant for Android distribution.

---

#### DeployGate
**Website:** https://deploygate.com

**Pros:**
- ✅ Fast distribution
- ✅ No app review
- ✅ Japanese company (if targeting Japan market)
- ✅ Simple upload and share link
- ✅ Analytics and crash reports
- ✅ Cross-platform

**Cons:**
- Smaller community than Firebase
- Limited free tier
- Less documentation in English

**Automation:**
- CLI: `dgate` CLI tool
- Fastlane: `deploygate` plugin
- GitHub Actions: Custom script with API
- Local build + upload: ✅ YES

**Quick Beta Capability:** ✅ GOOD
**Best For:** Simple distribution with Japanese support

**Pricing:**
- Free: 1 app, limited distribution
- Paid: $29/month for unlimited apps

---

#### App Center (Microsoft)
**Website:** https://appcenter.ms

**Pros:**
- ✅ Fast distribution
- ✅ No app review
- ✅ CI/CD built-in (can build and distribute)
- ✅ Crash reporting and analytics
- ✅ Push notifications
- ✅ Cross-platform
- ✅ Free tier available
- ✅ Good automation (CLI, API, Fastlane)

**Cons:**
- Requires Microsoft account
- Less popular than Firebase
- Some features behind paywall

**Automation:**
- CLI: `appcenter` CLI
- Fastlane: `appcenter` plugin
- GitHub Actions: Easy integration
- Local build + upload: ✅ YES

**Quick Beta Capability:** ✅ EXCELLENT
**Best For:** Teams using Microsoft ecosystem

**GitHub Actions Example:**
```yaml
- name: Distribute via App Center
  run: |
    npm install -g appcenter-cli
    appcenter distribute release \
      --app "YourOrg/YourApp" \
      --file app-release.apk \
      --group "Collaborators" \
      --token ${{ secrets.APPCENTER_TOKEN }}
```

---

#### HockeyApp (Deprecated - Migrated to App Center)
Note: HockeyApp has been shut down and migrated to Microsoft App Center.

---

### 1.3 Self-Hosted Distribution

#### GitHub Releases
**Website:** https://github.com

**Pros:**
- ✅ **Already have repo** - No additional setup
- ✅ **Free unlimited** storage and bandwidth
- ✅ **Easy to automate** - GitHub Actions built-in
- ✅ **Version control** - All releases tracked
- ✅ **Direct download** - Testers download APK directly

**Cons:**
- ⚠️ **No auto-update** - Testers must manually check for updates
- ⚠️ **Manual install process** - Users must enable "Unknown sources"
- No analytics or crash reporting
- No update notifications
- Less user-friendly than app stores

**Automation:**
- GitHub Actions: `softprops/action-gh-release`
- Local build + upload: ✅ YES (via `gh` CLI or git push)

**Quick Beta Capability:** ✅ GOOD (immediate, but manual for testers)
**Best For:** Open source projects, technical users, automation-first approach

**GitHub Actions Example:**
```yaml
name: Release APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Build APK
        run: |
          cd foc-companion
          flutter build apk --release
          
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: foc-companion/build/app/outputs/flutter-apk/app-release.apk
          body: |
            ## Beta Release
            Download and install APK directly on your device.
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Local CLI Example:**
```bash
# Build APK
cd foc-companion
flutter build apk --release

# Create GitHub release with gh CLI
gh release create v1.2.0-beta \
  ./build/app/outputs/flutter-apk/app-release.apk \
  --title "Beta v1.2.0" \
  --notes "New pattern system with driver cockpit"
```

---

#### Self-Hosted Website / S3
**Setup:** Your own server or cloud storage (S3, CloudFlare R2, etc.)

**Pros:**
- ✅ **Full control** - No platform restrictions
- ✅ **Free or low cost** (S3: ~$0.023/GB storage, $0.09/GB transfer)
- ✅ **Easy automation** - CLI upload, CI/CD
- ✅ **Direct download** - Simple link sharing

**Cons:**
- ⚠️ **No auto-update** (unless you build it)
- ⚠️ **No analytics** (unless you add them)
- Must handle HTTPS/certificates yourself (or use CDN)
- No built-in version management
- No update notifications

**Automation:**
- AWS CLI: `aws s3 cp app.apk s3://bucket/`
- GitHub Actions: `aws-actions/configure-aws-credentials`
- Local build + upload: ✅ YES

**Quick Beta Capability:** ✅ GOOD (immediate, but manual for testers)
**Best For:** Maximum control, cost-sensitive projects

**Example: S3 + CloudFront**
```bash
# Upload to S3
aws s3 cp app-release.apk s3://my-app-bucket/releases/v1.2.0/app.apk

# Share direct link with testers
https://d123456.cloudfront.net/releases/v1.2.0/app.apk
```

---

####PWABuilder / TWA (Trusted Web Activity)
**Website:** https://www.pwabuilder.com

**Note:** This is for web apps packaged as Android apps, not applicable for Flutter apps. Skip.

---

### 1.4 Direct Distribution Methods

#### Sideloading (Direct APK Install)
**Method:** Share APK file directly with testers

**Pros:**
- ✅ **Simplest method** - No platform needed
- ✅ **Immediate** - Send file, install
- ✅ **No registration** - Anyone with APK can install
- ✅ **Free**

**Cons:**
- ⚠️ **No update mechanism** - Must redistribute for each update
- ⚠️ **Security concerns** - Users must enable "Unknown sources"
- ⚠️ **Manual process** - No automation for testers
- No analytics, crash reports, or feedback

**Automation:**
- Can combine with GitHub Releases, S3, Firebase, etc.
- Distribution via email, Slack, Discord, messaging apps

**Quick Beta Capability:** ✅ EXCELLENT (for small groups)
**Best For:** Very small tester groups (1-5 people), internal testing

---

#### QR Code Distribution
**Method:** Generate QR code linking to APK download

**Pros:**
- ✅ **Easy mobile access** - Scan and download
- ✅ **Combine with any hosting** - GitHub Releases, S3, Firebase
- ✅ **Visual** - Great for presentations, docs

**Cons:**
- Still requires sideloading
- No automation for installation
- Must host APK somewhere

**Tools:**
- QR code generators: https://www.qr-code-generator.com/
- GitHub Pages + QR code for easy sharing

**Quick Beta Capability:** ✅ GOOD (easy for testers to access)
**Best For:** Conferences, presentations, quick sharing

---

### 1.5 Link-Based Testing Methods (No Email Required)

**Important:** For community beta testing, link-based methods eliminate the friction of collecting/managing tester emails.

#### Firebase App Distribution - Signup Links (RECOMMENDED)
**Method:** Create public signup link for tester self-registration

**How it works:**
1. Enable signup link in Firebase Console
2. Share link anywhere (Discord, website, social media)
3. Testers click link, sign in with Google account (once)
4. They automatically get access to all builds
5. Receive update notifications via Firebase app

**Setup:**
```
Firebase Console → App Distribution → Testers & Groups
→ Create Group → Enable "Share signup link"
```

**Example Link:**
```
https://appdistribution.firebase.google.com/testerapps/1:123456789:android:abcdef
```

**Pros:**
- ✅ **No email collection** - Testers self-register
- ✅ **Self-service** - No waiting for invitation
- ✅ **Shareable anywhere** - Discord, Slack, website, email
- ✅ **Still get all Firebase benefits** - Analytics, crash reports, update notifications
- ✅ **Control access** - Can disable link at any time
- ✅ **See who signed up** - Tester list in Firebase Console

**Cons:**
- ⚠️ Requires Google account for testers (one-time)
- ⚠️ Link can be shared beyond your control
- ⚠️ Less privacy than email invites

**Automation:**
- GitHub Actions: Same as email-based Firebase distribution
- Local CLI: Same as email-based
- Just share the signup link instead of adding individual emails

**Quick Beta Capability:** ✅ EXCELLENT (instant for testers)
**Best For:** Community beta testing, Discord communities, semi-public betas

**Discord Announcement Example:**
```markdown
🎮 **FOC Companion Beta Testing**

Want to test the latest features? Join our beta program!

📱 **Beta Signup:** https://appdistribution.firebase.google.com/...

After signing up, you'll get access to the latest beta builds 
and be notified when new versions are available.

**Requirements:**
- Android device
- FOC-Stim hardware  
- Google account (one-time signup)

Questions? Ask in #foc-companion-support
```

---

#### GitHub Releases - Direct Download Links
**Method:** Upload APK to release, share direct download link

**Setup:**
```bash
# Create release with APK
gh release create v1.0.0-beta ./app.apk --title "Public Beta v1.0.0"
```

**Share Direct Download Link:**
```
https://github.com/joywareapps/foc-companion/releases/download/v1.0.0-beta/app.apk
```

**Pros:**
- ✅ **No signup required** - Anyone with link can download
- ✅ **Already have setup** - GitHub repo exists
- ✅ **Version tracking** - All releases documented
- ✅ **Free unlimited** - No storage/bandwidth limits
- ✅ **Share anywhere** - Discord, website, email

**Cons:**
- ⚠️ **No auto-update** - Testers must manually check
- ⚠️ **No analytics** - Don't know who downloaded
- ⚠️ **Manual install** - Users must enable "Unknown sources"

**Quick Beta Capability:** ✅ EXCELLENT (instant download)
**Best For:** Open source projects, public betas, technical users

---

#### TestFairy - Public Links
**Method:** Each build gets shareable install link

**Setup:**
```bash
# Upload via API
curl -s -F "file=@app.apk" \
     -F "api_key=YOUR_KEY" \
     https://upload.testfairy.com/api/upload
```

**Share Link:**
```
https://testfairy.com/projects/joyware-apps/builds/123
```

**Pros:**
- ✅ **No signup for testers** - Click link, install
- ✅ **Session recording** - See how testers use app
- ✅ **Crash reports** - Detailed analytics
- ✅ **Feedback in-app** - Testers can report issues

**Cons:**
- ⚠️ **Free tier limited** - 2 apps, 500 MB storage
- ⚠️ **Paid plans** - $49/month for more
- ⚠️ **Privacy concerns** - Session recording

**Quick Beta Capability:** ✅ EXCELLENT
**Best For:** Teams wanting detailed testing analytics

---

#### App Center - Public Distribution Groups
**Method:** Create public group with shareable link

**Setup:**
```
App Center → Distribute → Groups → Create Group
→ Enable "Allow public access" → Get share link
```

**Pros:**
- ✅ **Free tier available** - Unlimited apps
- ✅ **Analytics included** - Usage tracking
- ✅ **No signup for testers** - Just download
- ✅ **Good automation** - CLI, API, GitHub Actions

**Cons:**
- ⚠️ Requires Microsoft account (for you, not testers)
- ⚠️ Less popular than Firebase

**Quick Beta Capability:** ✅ EXCELLENT
**Best For:** Microsoft ecosystem teams

---

#### S3/CloudFlare R2 - Direct Hosting
**Method:** Upload APK, share public URL

**Setup:**
```bash
# Upload to S3 with public access
aws s3 cp app.apk s3://my-bucket/beta/app.apk --acl public-read

# Share direct link
https://my-bucket.s3.amazonaws.com/beta/app.apk
```

**Pros:**
- ✅ **Maximum control** - You own everything
- ✅ **Extremely cheap** - <$1/month typically
- ✅ **No signup** - Direct download
- ✅ **CDN available** - Fast global delivery

**Cons:**
- ⚠️ **No updates/notifications** - Pure file hosting
- ⚠️ **No analytics** - Unless you add them
- ⚠️ **Manual management** - Version control, etc.

**Quick Beta Capability:** ✅ GOOD (instant, but manual)
**Best For:** Maximum control, cost-sensitive projects

---

### 1.6 Link-Based vs Email Comparison

| Method | Privacy | Friction | Control | Updates | Best For |
|--------|---------|----------|---------|---------|----------|
| **Email Invites** | High | High (wait) | High | ✅ Yes | Private betas, internal |
| **Firebase Signup Link** | Medium | Low (self-serve) | Medium | ✅ Yes | **Community betas** |
| **GitHub Releases** | Low | Very Low | Low | ❌ No | Public betas, OSS |
| **Direct APK Link** | Low | Very Low | Low | ❌ No | Quick sharing |

**Recommendation:**
- **Community Discord:** Firebase signup link (share once, testers self-register)
- **Public Website:** GitHub releases link (versioned, documented)
- **Internal Testing:** Firebase email invites (controlled access)

---

## Part 2: Comparison Matrix

### Quick Decision Matrix

| Platform | Speed | Automation | Cost | Update Notif. | Analytics | Best For |
|----------|-------|------------|------|---------------|-----------|----------|
| **Firebase App Distribution** | ✅ Immediate | ✅ Excellent | Free | ✅ Yes | ✅ Yes | **RECOMMENDED** for beta |
| GitHub Releases | ✅ Immediate | ✅ Excellent | Free | ❌ No | ❌ No | Open source, technical users |
| TestFairy | ✅ Immediate | ✅ Good | Paid | ✅ Yes | ✅ Yes | Teams wanting deep analytics |
| App Center | ✅ Immediate | ✅ Excellent | Free tier | ✅ Yes | ✅ Yes | Microsoft ecosystem |
| F-Droid | ⚠️ Slow (weeks) | ⚠️ Complex | Free | ✅ Yes | ❌ No | Open source production |
| DeployGate | ✅ Good | ✅ Good | Freemium | ✅ Yes | ✅ Yes | Japanese market |
| Amazon Appstore | ⚠️ Moderate | ❌ Poor | Free | ✅ Yes | ✅ Yes | Amazon devices |
| S3/CloudFlare | ✅ Immediate | ✅ Excellent | Low cost | ❌ No | ❌ No | Maximum control |

### Automation Score

| Platform | GitHub Actions | Local CLI | Fastlane | API |
|----------|---------------|-----------|----------|-----|
| **Firebase** | ✅ Official action | ✅ `firebase` CLI | ✅ Plugin | ✅ REST |
| GitHub Releases | ✅ Built-in | ✅ `gh` CLI | ✅ Plugin | ✅ REST |
| App Center | ✅ Easy | ✅ `appcenter` CLI | ✅ Plugin | ✅ REST |
| TestFairy | ✅ Custom script | ✅ API | ✅ Plugin | ✅ REST |
| S3 | ✅ AWS action | ✅ `aws` CLI | ✅ Plugin | ✅ SDK |
| F-Droid | ⚠️ Complex | ✅ `fdroidserver` | ❌ No | ❌ No |

---

## Part 3: Recommendation

### Recommended Approach: Multi-Tier Distribution

#### Tier 1: Rapid Beta Testing (Firebase Signup Links - RECOMMENDED)
**Use for:** Community testing, Discord members, semi-public betas

**Why Signup Links:**
- ✅ **No email management** - Testers self-register
- ✅ **Instant access** - Share link once, anyone can join
- ✅ **Still get updates** - Testers notified of new builds
- ✅ **Discord-friendly** - Perfect for community servers

**Setup:**
1. Create Firebase project
2. Enable App Distribution
3. Create tester group with signup link enabled
4. Share link in Discord #beta-testing channel
5. Testers self-register and get instant access

**Workflow:**
```yaml
name: Beta Distribution

on:
  push:
    branches: [develop]  # Or manual trigger

jobs:
  distribute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Build APK
        run: |
          cd foc-companion
          flutter build apk --release
          
      - name: Distribute to Firebase
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_CREDENTIALS }}
          groups: beta-testers  # Group with signup link enabled
          file: foc-companion/build/app/outputs/flutter-apk/app-release.apk
          releaseNotes: |
            Beta build from ${{ github.sha }}
            Changes: ${{ github.event.head_commit.message }}
```

**Benefits:**
- Testers see new builds immediately after signup
- No manual email management
- Update notifications built-in
- Crash reporting built-in (Crashlytics)
- Free tier sufficient for most apps
- Perfect for Discord communities

**Discord Announcement Template:**
```markdown
🎮 **[App Name] Beta Testing**

Join our beta program and test upcoming features!

📱 **Sign up here:** [Firebase Signup Link]

After signing up:
1. Install Firebase App Distribution app (link provided)
2. Download latest beta build
3. Install and start testing!

You'll be notified when new versions are available.

**Requirements:**
- Android device
- Google account (for one-time signup)
- [App-specific hardware/requirements]

Questions? Ask in #app-support
```

**Local Build + Upload:**
```bash
# Build locally
cd foc-companion
flutter build apk --release

# Upload via Firebase CLI
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups beta-testers \
  --release-notes "Local build - testing new features"
```

---

#### Tier 2: Public Beta (GitHub Releases)
**Use for:** Milestone builds, open beta testing, community testing

**Setup:**
1. Create GitHub release with APK
2. Share download link
3. Add install instructions to README

**Workflow:**
```yaml
name: Public Beta Release

on:
  push:
    tags:
      - 'v*-beta*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Build APK
        run: |
          cd foc-companion
          flutter build apk --release
          
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: foc-companion/build/app/outputs/flutter-apk/app-release.apk
          body: |
            ## Public Beta Release
            
            ### Installation
            1. Download APK from assets below
            2. Enable "Install from unknown sources" in Android settings
            3. Open APK and install
            4. See [README](../README.md) for usage instructions
            
            ### Changes
            - New pattern system with driver cockpit
            - Modulation support for pulse parameters
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Benefits:**
- Open to anyone with GitHub account
- Version history tracked
- No approval process
- Free unlimited downloads
- Easy to share link

**Local Build + Upload:**
```bash
# Build locally
cd foc-companion
flutter build apk --release

# Create release with gh CLI
gh release create v1.2.0-beta \
  ./build/app/outputs/flutter-apk/app-release.apk \
  --title "Public Beta v1.2.0" \
  --notes-file RELEASE_NOTES.md
```

---

#### Tier 3: Production Release (F-Droid)
**Use for:** Stable, production-ready releases to open-source community

**Setup:**
1. Ensure app meets F-Droid requirements (open source, reproducible build)
2. Submit to F-Droid via merge request to their repo
3. Consider self-hosted F-Droid repo for faster updates

**Benefits:**
- Reach open-source community
- Built-in update mechanism
- Trust from privacy-focused users

**Note:** This is for stable releases only, not beta testing.

---

## Part 4: Implementation Plan

### Phase 1: Firebase App Distribution (Immediate)

**Tasks:**
- [ ] Create Firebase project
- [ ] Enable App Distribution
- [ ] Add initial tester group (beta-testers)
- [ ] Create service account for CI/CD
- [ ] Add Firebase credentials to GitHub Secrets
- [ ] Create GitHub Actions workflow for beta distribution
- [ ] Test distribution with one build
- [ ] Document tester onboarding process

**GitHub Secrets Required:**
```
FIREBASE_APP_ID - From Firebase console
FIREBASE_CREDENTIALS - Service account JSON (base64 encoded)
```

**Tester Onboarding:**
1. Tester receives email invitation
2. Clicks link to accept invitation
3. Installs Firebase profile (one-time)
4. Downloads and installs APK
5. Gets notified of new builds automatically

---

### Phase 2: GitHub Releases (Optional, for public betas)

**Tasks:**
- [ ] Create release workflow
- [ ] Document manual release process
- [ ] Add installation instructions to README
- [ ] Create release notes template
- [ ] Test release process

---

### Phase 3: F-Droid (Future, for production)

**Tasks:**
- [ ] Ensure open source compliance
- [ ] Make build reproducible
- [ ] Document build process
- [ ] Submit to F-Droid
- [ ] Consider self-hosted repo for faster updates

---

## Part 5: Cost Analysis

### Firebase App Distribution
- **Free tier:** Unlimited testers, 2 GB/day downloads
- **Paid:** Blaze plan only if using other Firebase services
- **Estimated cost:** $0 (free tier sufficient)

### GitHub Releases
- **Cost:** $0 (free with GitHub account)
- **Storage:** Unlimited (soft limit ~1-2 GB per file)
- **Bandwidth:** Unlimited

### TestFairy
- **Free:** 2 apps, 500 MB storage
- **Pro:** $49/month/developer
- **Estimated cost:** $0-49/month depending on usage

### App Center
- **Free:** Unlimited apps, 4 GB/day downloads
- **Paid:** Visual Studio App Center is free for public repos
- **Estimated cost:** $0

### S3 + CloudFront
- **Storage:** $0.023/GB/month
- **Transfer:** $0.09/GB (first 10 TB/month)
- **Estimated cost:** <$1/month for typical app distribution

---

## Part 6: Decision Checklist

### Choose Firebase Signup Links if:
- ✅ Want no-hassle tester registration
- ✅ Testing with Discord/Slack community
- ✅ Want update notifications for testers
- ✅ Want analytics and crash reporting
- ✅ Don't want to manage email lists
- ✅ Using GitHub Actions or other CI/CD
- ✅ Want free solution
- **→ BEST FOR COMMUNITY BETA TESTING**

### Choose Firebase Email Invites if:
- ✅ Want controlled, private beta
- ✅ Know exactly who should have access
- ✅ Need to limit beta to specific people
- ✅ Want update notifications and analytics
- **→ BEST FOR PRIVATE/INTERNAL TESTING**

### Choose GitHub Releases if:
- ✅ Project is open source
- ✅ Want simplest setup (already have GitHub)
- ✅ Testers are technical users
- ✅ Don't need auto-updates or analytics
- ✅ Want zero cost
- ✅ Want versioned, documented releases
- **→ BEST FOR OPEN SOURCE PUBLIC BETAS**

### Choose TestFairy if:
- ✅ Want detailed session analytics
- ✅ Willing to pay for advanced features
- ✅ Need in-app feedback from testers
- ✅ Team wants comprehensive testing tools
- **→ BEST FOR DETAILED TESTING ANALYTICS**

### Choose App Center if:
- ✅ Using Microsoft ecosystem
- ✅ Want built-in CI/CD
- ✅ Want free tier with good limits
- ✅ Need cross-platform support
- **→ BEST FOR MICROSOFT-BASED TEAMS**

### Choose F-Droid if:
- ✅ App is fully open source
- ✅ Targeting privacy-focused users
- ✅ Don't mind slow review process
- ✅ Want permanent, discoverable distribution
- **→ BEST FOR PRODUCTION OPEN SOURCE RELEASES**

### Choose S3/CloudFlare if:
- ✅ Want maximum control
- ✅ Don't need update notifications
- ✅ Want lowest possible cost
- ✅ Comfortable with manual management
- **→ BEST FOR COST-SENSITIVE, CONTROL-FOCUSED PROJECTS**

---

## Deliverables

1. **Firebase Setup Guide** - Step-by-step setup instructions
2. **GitHub Actions Workflow** - Ready-to-use workflow file
3. **Tester Onboarding Doc** - Instructions for beta testers
4. **Local Build Script** - Script to build and upload locally
5. **Decision Matrix** - Summary for future reference

---

## Acceptance Criteria

- [ ] Research all major distribution platforms
- [ ] Document pros/cons of each option
- [ ] Identify best options for beta testing
- [ ] Provide GitHub Actions examples
- [ ] Provide local build + upload examples
- [ ] Create implementation plan
- [ ] Document cost analysis
- [ ] Make recommendation with rationale
