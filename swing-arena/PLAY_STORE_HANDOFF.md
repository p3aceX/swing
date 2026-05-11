# Swing Arena — Play Store Handoff

> **Pick up tomorrow from this file.** Everything below is the current
> state of the Play Store submission as of **2026-05-11 (today)**.

---

## 🔐 CRITICAL CREDENTIALS — back these up to a password manager

| Item | Value |
|---|---|
| Keystore file | `~/swing-arena-upload.keystore` |
| Keystore password | `YFI04T8Q4JrHdB73KSHv` |
| Key password (same) | `YFI04T8Q4JrHdB73KSHv` |
| Alias | `upload` |
| SHA1 fingerprint | `9B:34:7A:C1:6F:B8:68:8C:1A:FA:C6:D1:58:97:0C:C1:F1:3D:00:24` |
| SHA256 fingerprint | `DC:EC:08:BA:86:33:8C:63:E2:A8:13:A7:15:69:9D:D4:BC:1C:E1:09:58:73:61:C6:26:46:2F:34:EB:CB:5B:41` |

If the keystore file or password is ever lost, you lose the ability to
update the app on Play (unless Play App Signing is enabled, in which case
Google can reset the upload key).

---

## 📦 App identity

| Field | Value |
|---|---|
| Display name | **Swing Arena** |
| Package id (applicationId) | `com.swing.swing_arena` |
| Pubspec name | `swing_arena` |
| Version | `1.0.0` (build 1) |
| Play Console account | Organization (verified, ₹2k paid) |
| Firebase usage | **None** — Firebase plugin + google-services.json removed |
| Push notifications | OneSignal (no extra config needed) |

---

## 📁 Build artifacts

| Artifact | Path | Size |
|---|---|---|
| **Signed App Bundle (AAB)** | `build/app/outputs/bundle/release/app-release.aab` | 55 MB |
| Release APK (for sideload testing) | `build/app/outputs/flutter-apk/app-release.apk` | 71 MB |

Rebuild commands:

```bash
# AAB for Play Store
flutter build appbundle --release

# APK for sideload testing
flutter build apk --release
```

Verify signing:

```bash
jarsigner -verify build/app/outputs/bundle/release/app-release.aab
# should print: jar verified.
```

---

## ✅ What's done

- [x] Renamed swing-biz → swing-arena in monorepo (git rename detected)
- [x] All UI strings rebranded "Swing Biz" → "Swing Arena"
- [x] iOS `CFBundleDisplayName` + `CFBundleName` + Face ID prompt
- [x] Android `android:label` = "Swing Arena"
- [x] Pubspec name + description + version bumped to 1.0.0+1
- [x] Release signing config wired into `android/app/build.gradle.kts`
- [x] `android/key.properties` created (gitignored)
- [x] `.gitignore` excludes `*.keystore`, `*.jks`, `key.properties`
- [x] Generated upload keystore at `~/swing-arena-upload.keystore`
- [x] Renamed Android package `com.swing.swing_biz` → `com.swing.swing_arena`
- [x] MainActivity.kt moved to new package path, declaration updated
- [x] Removed `com.google.gms.google-services` plugin (no Firebase deps)
- [x] Deleted `google-services.json`
- [x] Built signed AAB — verified package id in manifest
- [x] All UI revamp from earlier in session (Performance section, tabs,
      booking card sizes, Indian comma money format, matchup tabs, etc.)
- [x] `flutter analyze` clean (0 errors)

### Git commits pushed to `origin/main`

| SHA | Message |
|---|---|
| `548c12a6` | refactor(biz→arena): rename swing-biz to swing-arena + UI revamp |
| `97f30bff` | chore(arena): prep for Play Store — rebrand to Swing Arena, release signing |
| `6c8df6ec` | fix(auth/role-selection): replace removed AppRoutes.chooseProfile with dashboard |
| `ec5b1a30` | refactor(android): rename package com.swing.swing_biz → com.swing.swing_arena |

---

## 🚧 What's left — Play Console submission checklist

App is **registered** on Play Console as `com.swing.swing_arena` and the AAB
is built. Still placeholder name "com.swing.swing_arena (unreviewed)" until
Store Listing is filled in.

### Required for Production submission

| Section | Status | Notes |
|---|---|---|
| Upload AAB to Internal testing | ⏳ | First step — confirms build is accepted |
| App access | ❌ | **CRITICAL** — provide demo phone+OTP for reviewer (e.g. `+91 99999 99999` with always-pass OTP `123456`) or they reject |
| Ads | ❌ | Declare yes/no |
| Content rating | ❌ | Fill out 5-min questionnaire |
| Target audience and content | ❌ | Age groups, kids-appeal toggle |
| News app | ❌ | No |
| COVID-19 contact tracing | ❌ | No |
| Data safety | ❌ | **CRITICAL** — declare data collected (phone, name, location?, booking/payment data). Google audits, so be honest |
| Government apps | ❌ | No |
| Financial features | ❌ | No |
| Health features | ❌ | No |
| Privacy policy URL | ❌ | **CRITICAL** — must be public URL. Notion / GitHub Pages OK |
| Store listing | ❌ | App name + short (80c) + full (4000c) description + icon 512×512 + feature graphic 1024×500 + ≥2 phone screenshots |
| App pricing | ❌ | Free, country selection (India + others) |

### Timeline (organization account, no 14-day closed-test rule)

- **Day 0 (today)**: AAB built, package id finalized
- **Day 0–1 (tomorrow)**: Finish Play Console checklist, upload AAB to Internal testing, sanity-check on phone, promote to Production
- **Day 1–4**: First Production review (organization priority: usually 2–4 days)
- **Day 3–7**: Live on Play Store

---

## 🛠️ Where things live in code

| Thing | File |
|---|---|
| App display title | `lib/app.dart` (`title: 'Swing Arena'`) |
| Welcome screen branding | `lib/features/auth/presentation/welcome_screen.dart` |
| Biometric prompt | `lib/core/auth/biometric_service.dart` |
| Home / Performance / Tabs | `lib/features/dashboard/presentation/dashboard_screen.dart` |
| Bookings page + grid tiles | `lib/features/bookings/presentation/bookings_page.dart` |
| Matchups tab (Find Team + Matchup Request) | `lib/features/bookings/presentation/matchups_tab.dart` |
| Indian money formatter `_compactAmount` | `lib/features/dashboard/presentation/dashboard_screen.dart` ≈ line 1657 |

---

## 🐛 Pre-submission smoke test list

Run these flows on the device after installing from Internal testing link:

- [ ] Open app — should show "Swing Arena" launcher icon
- [ ] Welcome → phone login → OTP → backend exchange → dashboard
- [ ] Biometric unlock works (Face ID prompt says "Swing Arena")
- [ ] Home: arena filter chips, Performance section (Today/Month tabs), Heatmap/Slot util/Revenue tabs
- [ ] Recent bookings carousel taps through to detail
- [ ] Bookings page: filter chips, date grid tiles, tap into date → bottom sheet with BookingCards
- [ ] Add booking flow end-to-end
- [ ] Matchups tab: Find Team + Matchup Request (no Requests tab)
- [ ] Logout → re-login

---

## 🤖 Resuming with Claude tomorrow

When you start a new Claude session, paste the user's message:
> "Resume from PLAY_STORE_HANDOFF.md — let's finish the Play Store submission."

Claude will:
1. Read this file
2. Read MEMORY.md (will already point to current state)
3. Pick up wherever you stopped

Key open questions for tomorrow:

- Do you have a public privacy policy URL ready? If not, I can draft a
  minimal one as a markdown page you can paste into Notion/GitHub Pages.
- Are screenshots ready? If not, I can guide you on `flutter run` →
  screenshot capture commands for clean 1080×1920 frames of the main
  screens (home, bookings, matchups).
- Demo credentials for Play reviewer — what test phone number can we
  give them?
