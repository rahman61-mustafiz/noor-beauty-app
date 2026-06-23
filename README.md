# Noor Beauty Salon — Mobile App

Developer handoff & technical documentation.

> The Android build is complete, signed, and tested (a release App Bundle is produced). This handoff covers configuring and publishing the **iOS** build. The codebase is **Flutter (cross-platform)**, so the remaining work is largely iOS *configuration* — not new feature development.

---

## 1. Tech Stack

**Mobile app**
- **Flutter (Dart)** — single codebase for Android & iOS
- REST calls via the `http` package (points to the live backend URL)
- Push notifications: **Firebase Cloud Messaging** (`firebase_core`, `firebase_messaging`)
- Local notifications: `flutter_local_notifications` — **pinned to `^19.5.0`** (v20+ breaks current code)
- Offer marquee: `marquee`
- App icons: `flutter_launcher_icons`
- Android specifics: core library desugaring enabled (`desugar_jdk_libs` 2.1.4), `compileSdk 34`

**Backend** (separate repo, already deployed — you do **not** need to run it for app work)
- Node.js + Express
- MongoDB via Mongoose
- Auth: JWT; admin MFA via TOTP (`otplib`)
- Image storage: AWS S3 (`@aws-sdk/client-s3`, `multer`)
- SMS OTP: AlphaSMS provider (via `axios`)
- Security: `helmet`, `cors`, `express-rate-limit`
- Hosted on **Railway** (auto-deploys on push)

**Admin panel**: a single-file HTML/JS SaaS panel that calls the same backend (used by salon staff). It is **not** part of the mobile build.

---

## 2. Repositories & Live Services

| Item | Value |
|---|---|
| App repo (private) | `rahman61-mustafiz/noor-beauty-app` |
| Backend repo (public) | `rahman61-mustafiz/noor-beauty-backend` |
| Backend base URL | `https://noor-beauty-backend-production.up.railway.app` |
| Android applicationId / iOS bundle id | `com.noorbeautysalon.app` |

---

## 3. Functional Scope (Requirements Reference)

There is no separate formal requirements document; this section is the functional spec.

**Authentication**
- Phone-number **OTP login, Bangladesh numbers only**. Accepts `01XXXXXXXXX`, `1XXXXXXXXX`, `+8801XXXXXXXXX`, `8801XXXXXXXXX`; foreign numbers are rejected. OTP is delivered by SMS and expires in 5 minutes.

**Customer home screen**
- Top offer/announcement **marquee** (text fetched live)
- **Featured banner** — image + 3 text lines, fetched live, can be toggled on/off
- **Services** list
- **Gallery / Home images** — fetched live, with a built-in fallback
- **Customer reviews** — fetched live, plus a "Rate us" submission

**Bookings** — create bookings (auto-confirmed).
**Notifications** — Firebase push + runtime permission (Android 13+ `POST_NOTIFICATIONS`).
**Account** — in-app account deletion (a public web page also exists for store-compliance).

**Admin (via the SaaS web panel, not the app)** — dashboard, bookings, services & service types, staff, reviews, gallery, home images, featured banner, announcement/offer text, ledger/account register, customers.

---

## 4. Theme
- Primary gold `#D4AF37`, dark `#1A1A1A`
- Font: **Open Sans**

---

## 5. Project Structure (key paths)
```
lib/
  screens/customer/home_screen.dart   # home: banner, gallery, reviews, offer marquee
  ...                                 # other screens, services, constants, theme
assets/
  images/                             # images + app-icon source
android/
  app/build.gradle                    # applicationId com.noorbeautysalon.app
  app/google-services.json            # Firebase Android config (included in zip)
  key.properties                      # signing config — NOT included (secret)
ios/                                  # to be generated / configured (see §7)
pubspec.yaml
```

---

## 6. Build & Run — Android (already working)
```bash
flutter pub get
flutter run                 # debug build on device/emulator
flutter build appbundle     # signed release AAB
# output: build/app/outputs/bundle/release/app-release.aab
```
Release signing uses `android/key.properties` + an upload keystore — both held by the owner and **not** in this zip.

---

## 7. iOS Setup — to be completed by the iOS developer
The Dart code is cross-platform; the work below is iOS configuration/publishing:

1. Generate the iOS project if absent: `flutter create --platforms=ios .`, then `cd ios && pod install`
2. Set **Bundle Identifier** to `com.noorbeautysalon.app`
3. **App icon** — regenerate iOS icons via `flutter_launcher_icons` (source asset in `assets/images/`)
4. **Firebase (iOS)** — add an iOS app in the project's Firebase console, download **`GoogleService-Info.plist`**, place it in `ios/Runner/`
5. **Push notifications** — create an **APNs Auth Key (.p8)** in the Apple Developer account, upload it to Firebase; in Xcode enable **Push Notifications** + **Background Modes → Remote notifications**
6. **Info.plist** — add usage strings (notifications; photo library if the image picker is used)
7. **Signing & ship** — select the Apple Developer team, archive in Xcode, upload to App Store Connect

> The Firebase project is owned by the app owner. Coordinate with them to register the iOS app / obtain `GoogleService-Info.plist` and to create the APNs key.

---

## 8. Backend / API (reference only — deployed & off-limits)
Base URL: `https://noor-beauty-backend-production.up.railway.app`
The app talks to this live URL; you do not need to run the backend locally.

**Public endpoints used by the app**
- `POST /api/auth/...` — phone OTP request & verify (JWT issued on success)
- `GET /api/services`, `GET /api/service-types`, `GET /api/staff`
- `POST /api/bookings` — create a booking
- `GET /api/reviews` (list) / `POST /api/reviews` (submit)
- `GET /api/gallery`, `GET /api/home-images`
- `GET /api/announcement` — offer marquee text
- `GET /api/banner` — featured banner content

**Admin endpoints** (`/api/admin/*`, TOTP-protected) power the SaaS panel: dashboard, customers, bookings, staff, services, service-types, reviews, analytics, reports, ledger, gallery, announcement, banner, home-images.

Backend environment variables (set on Railway; **secrets not included**): `MONGODB_URI`, `JWT_SECRET`, `SMS_PROVIDER`, `SMS_ALPHA_API_KEY`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`, `ADMIN_MFA_SECRET`, `AWS_REGION`, `S3_BUCKET`.

---

## 9. Secrets & What's NOT in this Zip (important)
Excluded for security; handle separately:
- Android upload keystore (`*.jks`) and `android/key.properties` — Android signing only (the iOS build uses its own Apple signing)
- `android/local.properties` — machine-specific SDK paths (auto-generated by Flutter)
- Backend `.env` / secrets — backend is already deployed

Included for convenience: `android/app/google-services.json` (Firebase **Android** client config).

---

## 10. Status & Roadmap
- ✅ **Android** — built, signed, tested; release AAB produced
- ⏳ **iOS** — configuration + App Store submission (this handoff)
- ✅ **Backend** — deployed & stable on Railway
- 🔜 Pending product items: admin ban/delete users, UI polish (card hover/glow), further design tweaks
