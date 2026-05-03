# Academy App — Onboarding Flow Spec

## Overview

5-screen linear flow. First time a user opens the app they go through:
Phone → (Name if new) → OTP → Business Details → Academy Registration → Dashboard

Every step maps 1:1 to a backend API call. No guessing. Follow this exactly.

---

## Base URL

```
https://api.swingcricket.in   (or your env base URL)
```

All endpoints below are relative to this base.

---

## Auth Strategy

- OTP via **Firebase Phone Auth**
- After Firebase verification → exchange Firebase `idToken` with backend → get `accessToken` + `refreshToken`
- Store both tokens securely (flutter_secure_storage)
- `accessToken` expires in **900 seconds (15 min)** — refresh using `POST /auth/refresh`
- All protected calls: `Authorization: Bearer <accessToken>` header

---

## Screen Flow

```
[1] Phone Entry
      │
      ├─ exists: true  ──────────────────────┐
      │                                       ↓
      └─ exists: false → [2] Name Entry → [3] OTP Verification
                                              │
                              ┌───────────────┴──────────────────┐
                              ↓                                   ↓
                    hasBusinessAccount: false         hasBusinessAccount: true
                              │                                   │
                    [4] Business Details               availableProfiles has 'ACADEMY'?
                              │                          No → [5] Academy Registration
                              ↓                          Yes → Dashboard
                    [5] Academy Registration
                              │
                              ↓
                          Dashboard
```

---

## Screen 1 — Phone Entry

**Purpose:** Collect phone number, check if account exists.

### UI
- Title: "Welcome"
- Subtitle: "Enter your mobile number to continue"
- Input: Phone number field
  - Type: phone / numeric
  - Prefix: country code picker (default +91)
  - Validation: minimum 10 digits after removing spaces/dashes
- Button: "Continue"

### API Call
```
POST /auth/check-phone

Body:
{
  "phone": "+919876543210"   // E.164 format — always include country code
}

Response:
{
  "success": true,
  "data": {
    "exists": boolean,
    "normalizedPhone": "+919876543210",
    "user": null | { "id": "...", "name": "..." }
  }
}
```

### Navigation
| Condition | Go to |
|---|---|
| `exists: true` | Screen 3 — OTP (skip name collection) |
| `exists: false` | Screen 2 — Name Entry |
| Network error | Show inline error, stay on screen |

### State to carry forward
- `normalizedPhone` from response (use this exact value in all future calls, not the raw input)
- `isNewUser = !exists`

---

## Screen 2 — Name Entry *(new users only)*

**Purpose:** Collect name before sending OTP.

### UI
- Title: "What's your name?"
- Subtitle: "This will appear on your academy profile"
- Input: Full name
  - Type: text, autocapitalize words
  - Validation: min 2 chars, max 100 chars, no leading/trailing spaces
- Button: "Send OTP"

### On Button Tap
1. Validate name locally
2. Trigger Firebase OTP for the `normalizedPhone` from Screen 1
   ```dart
   await FirebaseAuth.instance.verifyPhoneNumber(
     phoneNumber: normalizedPhone,
     verificationCompleted: ...,
     verificationFailed: ...,
     codeSent: (verificationId, resendToken) {
       // store verificationId
       navigateToOTPScreen(verificationId);
     },
     codeAutoRetrievalTimeout: ...,
   );
   ```
3. Navigate to Screen 3 carrying `verificationId` + `name`

### State to carry forward
- `name` (trimmed string)
- Firebase `verificationId`

---

## Screen 3 — OTP Verification

**Purpose:** Verify phone via Firebase OTP, exchange for backend tokens.

### UI
- Title: "Enter OTP"
- Subtitle: "Sent to `{normalizedPhone}`"
- Input: 6-digit OTP
  - Type: numeric, auto-focus, auto-submit on 6th digit
- Link: "Resend OTP" (enabled after 30s countdown)
- Button: "Verify"

### On Verify

**Step 1 — Verify with Firebase**
```dart
PhoneAuthCredential credential = PhoneAuthProvider.credential(
  verificationId: verificationId,
  smsCode: enteredOtp,
);
UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
String idToken = await result.user!.getIdToken();
```

**Step 2 — Exchange with backend**
```
POST /biz/login

Body:
{
  "idToken": "<firebase_id_token>",
  "name": "Rahul Sharma"    // ONLY include if isNewUser == true
}

Response:
{
  "success": true,
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "abc...",
    "expiresIn": 900,
    "isNewUser": boolean,
    "user": {
      "id": "cuid...",
      "name": "Rahul Sharma",
      "phone": "+919876543210",
      "activeRole": "BUSINESS_OWNER",
      "roles": ["BUSINESS_OWNER"]
    },
    "businessAccount": null | { ...business account object },
    "businessStatus": {
      "hasBusinessAccount": boolean,
      "businessAccountId": null | "cuid...",
      "availableProfiles": [],        // e.g. ["ACADEMY", "COACH"]
      "academyId": null | "cuid...",
      "coachProfileId": null | "cuid...",
      "arenaId": null | "cuid...",
      "managedArenaId": null | "cuid...",
      "storeIds": [],
      "storeAvailable": false
    }
  }
}
```

**Step 3 — Store tokens**
```dart
await secureStorage.write(key: 'accessToken', value: data.accessToken);
await secureStorage.write(key: 'refreshToken', value: data.refreshToken);
```

### Error Handling
| Error Code | Message to User |
|---|---|
| `NAME_REQUIRED` | "Please go back and enter your name" |
| `ACCOUNT_BANNED` | "Your account has been banned. Contact support." |
| `ACCOUNT_BLOCKED` | "Your account is blocked. Contact support." |
| Firebase `invalid-verification-code` | "Incorrect OTP. Please try again." |
| Firebase `session-expired` | "OTP expired. Tap resend." |

### Navigation
| Condition | Go to |
|---|---|
| `businessStatus.hasBusinessAccount == false` | Screen 4 — Business Details |
| `hasBusinessAccount == true` AND `!availableProfiles.includes('ACADEMY')` | Screen 5 — Academy Registration |
| `hasBusinessAccount == true` AND `availableProfiles.includes('ACADEMY')` | Dashboard |

### State to carry forward
- `accessToken`, `refreshToken` (stored)
- `businessStatus` object

---

## Screen 4 — Business Details

**Purpose:** Create the business account (legal/contact/banking info).

> **When shown:** Only when `businessStatus.hasBusinessAccount == false`

### UI — Two sections

#### Section A: Basic Info (show on screen, required to proceed)
| Field | Label | Type | Validation |
|---|---|---|---|
| `businessName` | Business / Academy Name | text | required, min 2, max 120 |
| `contactName` | Contact Person Name | text | optional, min 2, max 100 |
| `phone` | Contact Phone | phone | optional, min 10 digits |
| `email` | Contact Email | email | optional, valid email |
| `city` | City | text | optional, min 2 |
| `state` | State | dropdown or text | optional, min 2 |
| `address` | Address | multiline text | optional, min 5 |
| `pincode` | Pincode | numeric | optional, 4-10 chars |

#### Section B: Tax & Banking (collapsible / "Add later" option)
| Field | Label | Type | Validation |
|---|---|---|---|
| `gstNumber` | GST Number | text, uppercase | optional |
| `panNumber` | PAN Number | text, uppercase | optional |
| `beneficiaryName` | Account Holder Name | text | optional, max 120 |
| `accountNumber` | Bank Account Number | numeric text | optional, max 30 |
| `ifscCode` | IFSC Code | text, uppercase | optional, max 20 |
| `upiId` | UPI ID | text | optional, max 100 |

- Button: "Save & Continue"

### API Call
```
PUT /biz/business-details
Authorization: Bearer <accessToken>
Content-Type: application/json

Body:
{
  "businessName": "Sharma Cricket Academy",
  "contactName": "Rahul Sharma",         // optional
  "phone": "+919876543210",              // optional
  "email": "rahul@academy.com",          // optional
  "city": "Mumbai",                      // optional
  "state": "Maharashtra",                // optional
  "address": "123, MG Road",             // optional
  "pincode": "400001",                   // optional
  "gstNumber": "27AAAPZ2318J1ZY",        // optional
  "panNumber": "AAAPZ2318J",             // optional
  "beneficiaryName": "Rahul Sharma",     // optional
  "accountNumber": "1234567890",         // optional
  "ifscCode": "HDFC0001234",            // optional
  "upiId": "rahul@upi"                  // optional
}

Success Response:
{
  "success": true,
  "data": {
    "id": "cuid...",
    "userId": "cuid...",
    "businessName": "Sharma Cricket Academy",
    "onboardingComplete": true,
    ...all fields back
  }
}
```

### On Success → Navigate to Screen 5

---

## Screen 5 — Academy Registration

**Purpose:** Create the academy profile.

> **When shown:** After Business Details OR when `hasBusinessAccount == true` but `!availableProfiles.includes('ACADEMY')`

### UI
| Field | Label | Type | Validation |
|---|---|---|---|
| `name` | Academy Name | text | **required**, min 2, max 100 |
| `city` | City | text | **required**, min 2 |
| `state` | State | dropdown or text | **required**, min 2 |
| `description` | About Academy | multiline text | optional |
| `tagline` | Tagline | text | optional |
| `address` | Address | text | optional |
| `pincode` | Pincode | numeric | optional |
| `phone` | Academy Phone | phone | optional |
| `email` | Academy Email | email | optional, valid email |
| `websiteUrl` | Website | url | optional, valid URL |
| `foundedYear` | Founded Year | numeric | optional, 1800–2100 |
| `latitude` / `longitude` | Location Pin | map picker | optional (use device GPS or map) |

- Button: "Create Academy"

### API Call
```
POST /biz/academy
Authorization: Bearer <accessToken>
Content-Type: application/json

Body:
{
  "name": "Sharma Cricket Academy",        // REQUIRED
  "city": "Mumbai",                         // REQUIRED
  "state": "Maharashtra",                   // REQUIRED
  "description": "Top cricket academy",    // optional
  "tagline": "Train like a pro",           // optional
  "address": "123, MG Road",              // optional
  "pincode": "400001",                     // optional
  "phone": "+912222222222",               // optional
  "email": "info@academy.com",            // optional
  "websiteUrl": "https://academy.com",    // optional
  "foundedYear": 2015,                    // optional
  "latitude": 19.0760,                    // optional
  "longitude": 72.8777                    // optional
}

Success Response (201):
{
  "success": true,
  "data": {
    "id": "cuid...",
    "ownerId": "cuid...",
    "businessAccountId": "cuid...",
    "name": "Sharma Cricket Academy",
    "city": "Mumbai",
    "state": "Maharashtra",
    "planTier": "FREE",
    "maxStudents": 50,
    "isVerified": false,
    "isActive": true,
    "totalStudents": 0,
    "totalCoaches": 0,
    "totalBatches": 0,
    "createdAt": "2026-05-04T...",
    ...all other fields
  }
}
```

### Error Handling
| HTTP Status | Condition | Message to User |
|---|---|---|
| 400 | `BUSINESS_DETAILS_REQUIRED` | "Please complete business details first" → go back to Screen 4 |
| 400 | Zod validation | Show field-level errors |
| 401 | Token expired | Refresh token, retry |

### On Success → Navigate to Dashboard
Store the `academyId` from response — used for all future academy API calls.

---

## Token Refresh

Access token expires in 15 min. Implement an HTTP interceptor that:

1. On any `401` response → call refresh:
```
POST /auth/refresh
Content-Type: application/json

Body:
{
  "refreshToken": "<stored_refresh_token>"
}

Response:
{
  "success": true,
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "new_refresh_token...",   // token rotation — store this new one
    "expiresIn": 900
  }
}
```
2. Replace stored tokens
3. Retry original request
4. If refresh also fails with `401` (`REFRESH_TOKEN_INVALID`) → clear tokens → navigate to Screen 1

---

## Local State to Persist (across screens)

```dart
// After Screen 1
String normalizedPhone;
bool isNewUser;

// After Screen 2
String name;

// After Screen 3
String accessToken;      // secure storage
String refreshToken;     // secure storage
String userId;
String academyId;        // null until Screen 5 completes
BusinessStatus businessStatus;
```

---

## Error States (global)

| Scenario | Action |
|---|---|
| No internet | Show "No internet connection" snackbar, disable CTA |
| Server 500 | "Something went wrong. Please try again." |
| `ACCOUNT_BANNED` | Show modal, no retry, contact support link |
| `ACCOUNT_BLOCKED` | Show modal, no retry, contact support link |

---

## Endpoint Summary

| Screen | Method | Endpoint | Auth |
|---|---|---|---|
| 1 | POST | `/auth/check-phone` | None |
| 3 | POST | `/biz/login` | None (Firebase idToken) |
| 4 | PUT | `/biz/business-details` | Bearer token |
| 5 | POST | `/biz/academy` | Bearer token |
| Refresh | POST | `/auth/refresh` | None |
