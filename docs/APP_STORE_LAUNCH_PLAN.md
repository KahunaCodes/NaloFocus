# App Store Launch Plan

**Document Version:** 1.0
**Created:** 2025-01-14
**Target Launch:** Q1 2025 (4-5 weeks from start)
**Estimated Cost:** $130 initial + $114/year ongoing

---

## Executive Summary

This document outlines the complete plan to launch NaloFocus on the Mac App Store. Based on competitive analysis and technical assessment, we recommend a **$2.99 launch price** (not $0.99) and a **4-5 week timeline** to account for sandbox testing and potential App Store review iterations.

**Critical Success Factors:**
1. ✅ EventKit sandbox compatibility validation (Phase 2 priority)
2. ✅ Professional app icon and marketing materials
3. ✅ Comprehensive sandboxed environment testing
4. ✅ Privacy policy and compliance documentation

---

## Phase Breakdown

### Phase 1: Xcode Project Setup (2-3 days)

**Goal:** Convert SPM executable to App Store-ready Xcode project

#### Tasks
- [ ] Create new Xcode macOS app project
- [ ] Import existing SPM package as local dependency
- [ ] Configure bundle identifier: `com.kahunacodes.nalofocus`
- [ ] Set up Info.plist with required keys:
  - `NSRemindersUsageDescription`
  - `LSMinimumSystemVersion` (15.0)
  - `LSUIElement` (YES for menu bar app)
  - `CFBundleDisplayName`
- [ ] Create app icon asset catalog (1024x1024 + all required sizes)
- [ ] Remove DEBUG mode, ensure RELEASE-only builds
- [ ] Configure build settings:
  - Enable hardened runtime
  - Set deployment target (macOS 15.0)
  - Configure signing identity placeholder
- [ ] Test build parity with SPM version
- [ ] Document build process for future updates

#### Deliverables
- Xcode project file (`.xcodeproj`)
- Complete Info.plist configuration
- App icon asset catalog
- Build documentation

#### Risk Level: **Low**
#### Dependencies: None

---

### Phase 2: App Store Compliance (3-5 days) ⚠️ CRITICAL PHASE

**Goal:** Ensure app meets all App Store technical requirements

#### Tasks
- [ ] Enable App Sandbox in entitlements:
  ```xml
  <key>com.apple.security.app-sandbox</key>
  <true/>
  <key>com.apple.security.personal-information.calendars</key>
  <true/>
  ```
- [ ] **CRITICAL:** Test EventKit in sandboxed environment
  - Build with sandbox enabled
  - Test reminder fetching
  - Test reminder creation
  - Test reminder updates
  - Verify all permissions prompts work
  - Document any sandbox-specific issues
- [ ] Add Privacy Manifest (`PrivacyInfo.xcprivacy`):
  - Declare EventKit API usage
  - Specify data collection (none)
  - Document tracking practices (none)
- [ ] Verify no prohibited API usage (private frameworks, etc.)
- [ ] Test menu bar functionality in sandboxed environment
- [ ] Ensure RELEASE mode works without DEBUG dependencies
- [ ] Remove any development-only code paths
- [ ] Validate all permissions are properly requested

#### Deliverables
- Fully sandboxed build
- Privacy manifest file
- Entitlements configuration
- Sandbox compatibility test report

#### Risk Level: **HIGH**
#### Dependencies: Phase 1 complete
#### Contingency: If EventKit sandbox issues found, budget +3-7 days for resolution

---

### Phase 3: Code Signing & Developer Setup (1-2 days)

**Goal:** Configure Apple Developer account and code signing

#### Tasks
- [ ] Purchase Apple Developer Program ($99/year)
  - Wait 1-2 days for account activation
- [ ] Create distribution certificate:
  - Open Xcode → Preferences → Accounts
  - Add Apple ID
  - Manage Certificates → Create "Developer ID Application"
  - Download and install certificate
- [ ] Create App ID in App Store Connect:
  - Bundle ID: `com.kahunacodes.nalofocus`
  - Enable Reminders capability
- [ ] Create provisioning profile for distribution
- [ ] Configure Xcode project with signing:
  - Select development team
  - Choose automatic or manual signing
  - Verify certificate and profile selection
- [ ] Test signed build on clean machine (non-development Mac)
- [ ] Set up notarization workflow:
  - Create app-specific password
  - Configure `notarytool` credentials
  - Test notarization process with archive

#### Deliverables
- Active Apple Developer account
- Distribution certificate installed
- Provisioning profile configured
- Notarization workflow documented

#### Risk Level: **Low**
#### Dependencies: Phase 2 complete
#### Cost: $99 (Apple Developer Program)

---

### Phase 4: Marketing Materials (2-4 days)

**Goal:** Create all required App Store assets and supporting materials

#### Tasks

**App Icon (High Priority)**
- [ ] Design 1024x1024 app icon following Apple HIG
  - Simple, recognizable design
  - Works at small sizes (16x16 menu bar)
  - Consistent with macOS design language
- [ ] Option A: Hire designer ($50-200)
- [ ] Option B: Design yourself using SF Symbols + design tool
- [ ] Generate all required sizes for asset catalog
- [ ] Test icon in menu bar at 1x and 2x resolutions

**Screenshots (Required: 5+)**
- [ ] Capture on multiple display sizes:
  - 13" MacBook (2560x1600)
  - 15" MacBook (2880x1800)
  - 27" iMac (5120x2880)
- [ ] Screenshot 1: Main sprint dialog with tasks selected
- [ ] Screenshot 2: Duration assignment step
- [ ] Screenshot 3: Timeline preview
- [ ] Screenshot 4: Menu bar integration
- [ ] Screenshot 5: Success confirmation with scheduled reminders
- [ ] Add descriptive captions to each screenshot
- [ ] Ensure screenshots show compelling use case

**App Store Copy**
- [ ] Write app description (2-3 paragraphs):
  - What problem does it solve?
  - How does it work?
  - Key benefits (time blocking, menu bar access, etc.)
- [ ] Create keyword list (max 100 characters):
  - Focus on: reminders, sprint, time blocking, productivity, menu bar
- [ ] Write promotional text (170 characters)
- [ ] Draft release notes for version 1.0

**Privacy Policy**
- [ ] Create privacy policy page (required for EventKit access)
- [ ] Content to include:
  - Data access: Only local Apple Reminders
  - No cloud storage or external servers
  - No user tracking or analytics
  - How EventKit permission is used
- [ ] Host privacy policy:
  - Option A: GitHub Pages (free)
  - Option B: Simple static site hosting
- [ ] Get publicly accessible URL

**Support Infrastructure**
- [ ] Set up dedicated support email: `support@nalofocus.app` (or similar)
- [ ] Create support URL (can be GitHub issues or simple contact page)
- [ ] Draft FAQ document:
  - How to grant Reminders permission
  - How to create sprints
  - Troubleshooting common issues
  - System requirements

#### Deliverables
- Professional app icon (all sizes)
- 5+ high-quality screenshots
- Complete App Store copy
- Privacy policy (hosted and accessible)
- Support email and URL
- FAQ documentation

#### Risk Level: **Low**
#### Dependencies: Phase 2 complete (for accurate screenshots)
#### Cost: $0-200 (if hiring icon designer)

---

### Phase 5: Testing & Polish (3-5 days)

**Goal:** Comprehensive quality assurance before submission

#### Tasks

**Functional Testing**
- [ ] Test all core workflows in sandboxed environment:
  - Launch from menu bar
  - Permission grant flow (fresh install simulation)
  - Reminder fetching (0 reminders, 100+ reminders)
  - Task selection (1 task, 9 tasks, edge cases)
  - Duration assignment (various durations)
  - Break insertion
  - Timeline preview accuracy
  - Sprint creation and Reminders update
  - Success/error state handling
- [ ] Test error scenarios:
  - Permission denied
  - No reminders available
  - EventKit errors
  - Concurrent reminder modifications
- [ ] Test on clean macOS installation (VM or separate machine)
- [ ] Test with multiple Reminder accounts (iCloud, Local, Exchange)

**Compatibility Testing**
- [ ] Test on macOS 15.0 (Sequoia) minimum
- [ ] Test on different Mac hardware:
  - MacBook Air (lower performance)
  - MacBook Pro (typical user)
  - iMac (desktop display)
- [ ] Test on 1x and 2x (Retina) displays
- [ ] Verify menu bar icon renders correctly at all sizes

**Performance Testing**
- [ ] Measure app launch time (<2 seconds target)
- [ ] Test with large reminder lists (100+ reminders)
- [ ] Monitor memory usage during typical session
- [ ] Check CPU usage (should be minimal when idle)
- [ ] Verify no memory leaks during repeated use

**Accessibility Testing**
- [ ] Test with VoiceOver enabled:
  - All UI elements have labels
  - Logical navigation flow
  - Actions are announced correctly
- [ ] Test keyboard navigation (full keyboard access)
- [ ] Verify color contrast meets WCAG AA standards
- [ ] Test with Reduce Motion enabled
- [ ] Test with Increase Contrast enabled

**Beta Testing**
- [ ] Recruit 3-5 beta testers (friends, colleagues)
- [ ] Distribute via TestFlight or direct .app distribution
- [ ] Collect feedback on:
  - User experience clarity
  - Bug reports
  - Feature requests
  - Onboarding ease
- [ ] Iterate based on feedback

**Polish & Bug Fixes**
- [ ] Fix all critical bugs discovered in testing
- [ ] Address high-priority UI/UX issues
- [ ] Optimize performance bottlenecks
- [ ] Refine error messages and user guidance
- [ ] Final code review and cleanup

#### Deliverables
- Test report documenting all scenarios
- Bug fixes implemented
- Performance metrics documented
- Accessibility compliance verified
- Beta tester feedback summary

#### Risk Level: **Medium**
#### Dependencies: Phases 1-4 complete
#### Contingency: Budget +2-3 days if major issues discovered

---

### Phase 6: App Store Submission (1-2 days + 1-7 days Apple review)

**Goal:** Submit app to App Store and navigate review process

#### Tasks

**Pre-Submission Checklist**
- [ ] Verify all previous phases complete
- [ ] Create production archive in Xcode (Product → Archive)
- [ ] Validate archive (Xcode Organizer → Validate App)
- [ ] Fix any validation errors/warnings
- [ ] Notarize the build
- [ ] Test notarized build on clean machine

**App Store Connect Setup**
- [ ] Log into App Store Connect (appstoreconnect.apple.com)
- [ ] Create new macOS app:
  - Bundle ID: `com.kahunacodes.nalofocus`
  - App Name: "NaloFocus"
  - Primary Language: English (U.S.)
  - Category: Productivity
  - Subcategory: Task Management
- [ ] Fill in App Information:
  - Privacy Policy URL
  - Support URL
  - Marketing URL (optional)
  - Copyright notice
- [ ] Upload screenshots (all required sizes)
- [ ] Enter app description and keywords
- [ ] Set pricing: **$2.99** (recommended) or $0.99
- [ ] Select availability (all territories or specific regions)
- [ ] Configure age rating (likely 4+, no objectionable content)
- [ ] Add release notes for version 1.0

**Build Upload**
- [ ] Upload archive via Xcode Organizer (Upload to App Store)
- [ ] Wait for build processing (5-30 minutes)
- [ ] Select uploaded build in App Store Connect
- [ ] Add "What's New" text for this version
- [ ] Set version number: 1.0.0
- [ ] Configure build settings:
  - Export compliance (no encryption beyond HTTPS)
  - Content rights documentation

**Submit for Review**
- [ ] Double-check all information is complete
- [ ] Review App Store preview
- [ ] Submit for review
- [ ] Monitor email for review status updates
- [ ] Check App Store Connect daily for status changes

**Review Process**
- [ ] Apple review typically takes 1-7 days
- [ ] Possible outcomes:
  - **Approved:** App goes live (or on scheduled date)
  - **Rejected:** Review feedback, fix issues, resubmit
  - **In Review:** App is being tested by Apple reviewers
  - **Metadata Rejected:** Fix app description/screenshots only
- [ ] If rejected, carefully read rejection reason
- [ ] Address all issues mentioned
- [ ] Respond via Resolution Center if needed
- [ ] Resubmit (review time: 1-3 days typically faster)

**Post-Approval**
- [ ] Verify app appears in App Store search
- [ ] Test download and installation from App Store
- [ ] Monitor initial user reviews
- [ ] Respond to any critical issues immediately
- [ ] Prepare for first update cycle (bug fixes, improvements)

#### Deliverables
- Uploaded and approved build
- Complete App Store listing
- App live on Mac App Store
- Launch announcement prepared

#### Risk Level: **Medium**
#### Dependencies: All previous phases complete
#### Contingency: Budget +3-5 days for rejection iteration

---

## Timeline Summary

```
Week 1:
├─ Days 1-2: Phase 1 (Xcode Setup)
├─ Days 3-5: Phase 2 (Sandbox Testing) ← CRITICAL
└─ Days 6-7: Phase 3 (Code Signing)

Week 2:
├─ Days 8-11: Phase 4 (Marketing Materials)
└─ Days 12-14: Phase 5 (Testing) begins

Week 3:
├─ Days 15-17: Phase 5 (Testing) continues
├─ Day 18: Phase 6 (Submission)
└─ Days 19-21: Apple Review in progress

Week 4:
├─ Days 22-25: Apple Review continues OR Rejection iteration
└─ Day 26+: Approval and launch

Total: 3-4 weeks (optimistic) | 4-5 weeks (realistic with buffer)
```

---

## Cost Summary

### Initial Investment
| Item | Cost | Required? |
|------|------|-----------|
| Apple Developer Program | $99/year | ✅ Required |
| Domain name (privacy/support) | $10-15/year | Recommended |
| Web hosting | $0-10/month | Optional (use GitHub Pages) |
| App icon design | $50-200 | Optional (DIY possible) |
| **Total** | **$109-324** | |

### Ongoing Costs
| Item | Annual Cost |
|------|-------------|
| Apple Developer renewal | $99 |
| Domain renewal | $15 |
| Hosting (if paid) | $0-120 |
| **Total** | **$114-234/year** |

### Revenue Projections

**At $0.99 pricing:**
- Keep: $0.69/sale (year 1), $0.84/sale (year 2+)
- Break-even: 189 sales
- $1000 revenue: 1,450 sales

**At $2.99 pricing (RECOMMENDED):**
- Keep: $2.09/sale (year 1), $2.54/sale (year 2+)
- Break-even: 63 sales
- $1000 revenue: 479 sales

---

## Risk Register

| Risk | Impact | Probability | Mitigation | Timeline Impact |
|------|--------|-------------|------------|-----------------|
| EventKit sandbox incompatibility | Critical | Medium | Test early (Phase 2), research alternatives | +3-7 days |
| App Store rejection | High | Medium | Follow guidelines, comprehensive testing | +3-5 days |
| macOS 15.0+ limited user base | Medium | High | Consider backporting to macOS 14.0 | +2-5 days |
| Icon design quality issues | Medium | Low | Hire professional designer or iterate | +1-2 days |
| Beta testing reveals major UX issues | High | Low | Early user testing, iterate on feedback | +2-4 days |
| Notarization issues | Medium | Low | Test workflow early, verify settings | +1 day |
| Privacy policy compliance issues | Medium | Low | Use standard template, legal review | +1 day |

---

## Success Criteria

### Technical Success
- ✅ App runs in App Sandbox without issues
- ✅ All EventKit operations work correctly
- ✅ Zero crashes during testing (100 test sessions)
- ✅ Passes all App Store validation checks
- ✅ Successfully notarized and installable

### Quality Success
- ✅ VoiceOver accessibility fully functional
- ✅ App launch time <2 seconds
- ✅ Beta testers report positive experience (4/5+ rating)
- ✅ No critical bugs in final build
- ✅ Professional appearance (icon, screenshots, copy)

### Business Success
- ✅ App approved on first or second submission
- ✅ Launch within 4-5 week timeline
- ✅ Total costs under $200 (excluding developer fee)
- ✅ 100 downloads in first month (realistic target)
- ✅ 4+ star average rating after 10 reviews

---

## Pricing Recommendation

### ❌ Against $0.99 Pricing
- Positions app as low-quality or feature-limited
- Extremely difficult to profit (need 189 sales to break even)
- Race to bottom in App Store pricing
- Leaves no room for promotional discounts
- Users question value at impulse-purchase price

### ✅ Recommend $2.99 Pricing
- Sustainable indie app business model
- Only need 63 sales to break even
- Positions as quality productivity tool
- Room for launch promotions ($1.99 first month)
- Aligns with similar apps (Gestimer $2.99)
- 3x more revenue per sale ($2.09 vs $0.69)

### Alternative: $4.99 Pricing
- Matches TimeFinder (main competitor)
- Premium positioning
- Higher revenue per sale ($3.49)
- May reduce conversion rate
- Consider for v2.0 with more features

**Recommended Launch Strategy:**
1. Launch at $2.99 regular price
2. Promotional price $1.99 for first 2 weeks
3. Announce on social media, ProductHunt, Reddit
4. Monitor conversion rates and adjust if needed
5. Never drop below $2.99 long-term

---

## Post-Launch Plan (First 30 Days)

### Week 1 Post-Launch
- [ ] Monitor crash reports in App Store Connect
- [ ] Respond to all user reviews (thank positive, address negative)
- [ ] Track download numbers daily
- [ ] Fix any critical bugs discovered
- [ ] Gather user feedback via support email

### Week 2-4 Post-Launch
- [ ] Analyze user reviews for common feature requests
- [ ] Plan version 1.1 update (bug fixes + minor improvements)
- [ ] Create social media presence (Twitter, ProductHunt)
- [ ] Write blog post about development journey
- [ ] Reach out to Mac productivity blogs for coverage
- [ ] Consider Reddit posts in r/macapps, r/productivity
- [ ] Monitor competitor updates

### First Update (v1.1 Target: 2-4 weeks post-launch)
- [ ] Address top user-reported bugs
- [ ] Implement quick-win feature requests
- [ ] Performance optimizations based on crash reports
- [ ] Submit update to App Store
- [ ] Use update to generate renewed interest

---

## Appendix: Technical Considerations

### macOS Version Support Decision

**Current: macOS 15.0+ (Sequoia)**
- Uses MenuBarExtra API (requires 15.0+)
- Very limited user base (Sequoia released Sept 2024)
- Estimated <10% of Mac users on Sequoia in Q1 2025

**Option: Backport to macOS 14.0 (Sonoma)**
- Replace MenuBarExtra with NSStatusItem (older but compatible API)
- Expands user base to ~40% of Mac users
- Additional development time: 2-5 days
- Recommended if targeting broader audience

**Decision Point:** Evaluate after Phase 2 sandbox testing. If development is smooth, consider backporting for v1.0. If tight on timeline, launch with 15.0+ and backport in v1.1.

### Sandbox Entitlements Required

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Enable App Sandbox -->
    <key>com.apple.security.app-sandbox</key>
    <true/>

    <!-- Calendar/Reminders Access -->
    <key>com.apple.security.personal-information.calendars</key>
    <true/>

    <!-- Outgoing Network (if analytics added later) -->
    <key>com.apple.security.network.client</key>
    <false/>

    <!-- Hardened Runtime -->
    <key>com.apple.security.cs.allow-jit</key>
    <false/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <false/>
</dict>
</plist>
```

### Info.plist Required Keys

```xml
<!-- Reminders Permission -->
<key>NSRemindersUsageDescription</key>
<string>NaloFocus needs access to create time-blocked work sprints from your unscheduled reminders.</string>

<!-- Menu Bar App (no Dock icon) -->
<key>LSUIElement</key>
<true/>

<!-- Minimum System Version -->
<key>LSMinimumSystemVersion</key>
<string>15.0</string>

<!-- App Category -->
<key>LSApplicationCategoryType</key>
<string>public.app-category.productivity</string>
```

---

## Resources & References

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [macOS App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)
- [EventKit Framework](https://developer.apple.com/documentation/eventkit)
- [Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

### Design Resources
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [SF Symbols](https://developer.apple.com/sf-symbols/) (for icon design)
- [App Icon Generator](https://www.appicon.co/) (free tool)

### Privacy Policy Templates
- [App Privacy Policy Generator](https://app-privacy-policy-generator.firebaseapp.com/)
- [TermsFeed Privacy Policy Generator](https://www.termsfeed.com/privacy-policy-generator/)

### Marketing
- [ProductHunt](https://www.producthunt.com/) (launch platform)
- [MacMenuBar.com](https://macmenubar.com/) (directory for menu bar apps)
- r/macapps, r/productivity (Reddit communities)

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-14 | Initial launch plan created based on competitive analysis |

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Decide on pricing** ($0.99 vs $2.99 vs $4.99)
3. **Decide on macOS support** (15.0+ only vs backport to 14.0)
4. **Begin Phase 1** (Xcode project setup)
5. **Purchase Apple Developer Program** (start 1-2 day activation)
6. **Design or commission app icon** (can run parallel to Phase 1-2)

**Ready to proceed?** Start with Phase 1 and prioritize sandbox testing in Phase 2.
