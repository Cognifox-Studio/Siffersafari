# Privacy Policy – Siffersafari

**Last Updated:** October 29, 2026

## Overview

Siffersafari is a mathematics game app designed for children ages 6–12. This Privacy Policy explains how we handle data when you use our app.

**Default mode:** Gameplay data is stored **locally on your device**. We do not require an account to play.

**Optional cloud backup (parent opt-in):** When enabled by a parent/guardian behind the parent PIN, progress may be copied to **Google Firebase** (Authentication + Firestore) so it can be restored on a new device. This is **off by default** and not required for any core feature.

## Data We Collect

**Without cloud backup:** We do not operate a central account system and do not collect child email, address, or location.

**With cloud backup enabled by a parent:** We store the minimum needed to restore learning progress (profile name, scores, unlocks, session summaries) in **Firebase Firestore**, tied to the **parent’s** sign-in. Child profiles are not separate login accounts.

We do **not** collect:
- ❌ Photos, videos, or audio recordings for upload
- ❌ GPS / precise location
- ❌ Cross-app advertising identifiers
- ❌ Analytics or behavioral tracking (no Firebase Analytics, no ad SDKs)

## Data We Store Locally

The following information is stored **only on your device** using encrypted local storage:

| Data Type | Purpose | Stored Where |
|-----------|---------|--------------|
| Child profile name | Identify user in app | Device storage (Hive) |
| Quiz scores & results | Track learning progress | Device storage (Hive) |
| Progress (operation unlocks) | Unlock new difficulty levels | Device storage (Hive) |
| Parent PIN (hashed) | Parent access control | Device storage (Hive), encrypted with BCrypt |
| Session history | Cumulative statistics | Device storage (Hive) |

**Local-first:** Hive remains the source of truth while playing offline.

### Optional cloud copy (Firebase)

When a parent turns on cloud backup:

| Data Type | Purpose | Stored Where |
|-----------|---------|--------------|
| Child profile + progress snapshot | Restore after device change | Firebase Firestore (EU/US per Firebase project region) |
| Parent sign-in identifier | Secure access to that household’s backup | Firebase Authentication |

You can turn cloud backup off in parent settings; deleting the parent account or all data should remove cloud copies (see Phase 2 implementation in app release notes).

## Data NOT Collected

- ❌ **No analytics or ads:** No Google Analytics, **Firebase Analytics**, Mixpanel, or ad networks
- ❌ **No behavioral tracking** across apps or websites
- ❌ **No selling data** to third parties

Without cloud backup enabled, child progress does not leave the device.

## How You Control Your Data

### Delete a Child's Profile
1. Open Siffersafari app
2. Go to **Settings** (gear icon)
3. Select the child's profile
4. Tap **Delete Profile**
5. Confirm deletion

Profile data (quizzes, progress) is permanently deleted from the device.

### Clear All Data
1. Open Siffersafari app
2. Go to **Settings** → **Advanced**
3. Tap **Clear All Data**
4. Confirm deletion

All profiles, scores, and settings are erased. This cannot be undone.

### Access Your Data
All stored data is on YOUR device. There is **no cloud export button** in the app.

To review progress:
- Open the child profile in the app (home, badges, parent dashboard)

To remove data:
- Delete a profile or use **Clear All Data** under Settings (see above)
- Uninstalling the app also removes local Hive data on that device

Advanced users who need a raw copy can use platform backup tools for the app’s private storage; Siffersafari does not ship a file-export flow.

## Data Security

Your data is protected by:
- **Local Encryption:** Parent PINs are hashed using BCrypt (not stored in plain text)
- **Device Storage:** Data stored in Hive encrypted box on your device
- **No Network Transmission:** No encryption needed since data never leaves your device
- **No Account/Password System:** No account means no credential breach risk

## Children's Privacy (COPPA)

Siffersafari is designed for children under 13. We comply with **COPPA** by:
1. **No child login** — children use local profiles; any cloud account is **parent/guardian** only
2. **Opt-in cloud backup** — off by default; enabled only behind the parent PIN
3. **No ads or analytics SDKs** in the app
4. **Easy deletion** on device (and cloud deletion when backup is enabled — see in-app controls)

## Third-Party Services

**Offline libraries** (device only): Hive, Riverpod, bcrypt — no phone-home.

**Optional cloud (only when backup is on):**
- **Firebase Authentication** — parent sign-in
- **Cloud Firestore** — encrypted in transit (HTTPS/TLS); access controlled by security rules

We do **not** embed Firebase Analytics, Crashlytics with user profiling, or Firebase Ads.

## Data Retention

We retain data only as long as necessary:
- **Child Profile Data:** Stored until you delete the profile
- **Parent PIN:** Stored until you delete the profile
- **Cache/Temporary Files:** Automatically cleared during normal app updates

We have **no centralized database**, so all data deletion is instant and permanent.

## Your Rights

As a parent/guardian, you have the right to:
- ✅ Know what data the app stores (see full list above)
- ✅ Delete your child's profile and all associated data anytime
- ✅ Request that we explain our data practices
- ✅ Contact us with privacy questions (see below)

## Changes to This Policy

If our data practices change, we will update this policy and notify users in the next app update. Continued use of the app after updates means acceptance of the new policy.

## Contact Us

For privacy questions or concerns:
- **Project page:** https://github.com/Cognifox-Studio/Siffersafari
- **Security contact:** https://github.com/Cognifox-Studio/Siffersafari/security

For reports of COPPA violations, contact:
- **Federal Trade Commission:** [CoppaHotline@ftc.gov](mailto:CoppaHotline@ftc.gov)

## Compliance Summary

✅ **COPPA-minded:** No child accounts; optional parent-gated backup only  
✅ **Offline-first core:** Play without network  
✅ **No analytics/ads SDKs**  
✅ **Transparent:** This policy describes local and optional cloud handling

---

**Questions?** We're happy to explain. Contact us above.
