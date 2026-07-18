# BalGyan (working title)

Trilingual (हिंदी / मराठी / English) offline-first learning app for toddlers (1.5–5):
ABCD + Numbers 1–10. No ads, no login, no network calls — everything ships inside the app.

Flutter, single codebase for Android (min SDK 24) + iOS (min 13). Portrait-locked.
Web is enabled as a dev/demo target only (`flutter run -d chrome`).

## Run

```sh
flutter pub get
flutter run          # device/emulator
flutter run -d chrome  # quick demo in browser
flutter test
```

## ⚠️ Placeholder assets — replace before release

All illustrations and voiceovers are machine-generated placeholders. Replace files
**1:1 with the same filenames** and nothing else needs to change:

| What | Where | Placeholder source |
|---|---|---|
| Letter/number art | `assets/images/letters/*.png`, `assets/images/numbers/*.png` | PIL-drawn cards |
| English voiceover | `assets/audio/en/*.m4a` | macOS TTS (Samantha) |
| Hindi voiceover | `assets/audio/hi/*.m4a` | macOS TTS (Lekha) |
| **Marathi voiceover** | `assets/audio/mr/*.m4a` | **currently the Hindi voice** — needs a real Marathi voice artist |
| Quiz sounds | `assets/audio/fx/correct.m4a`, `try_again.m4a` | macOS TTS |
| App icon | `assets/icons/app_icon.png` | then run `dart run flutter_launcher_icons` |

Audio format is AAC/.m4a (64kbps mono recommended for final recordings — the spec's
size budget assumes compressed audio). Filenames must stay identical across the three
language folders; the app resolves `assets/audio/{lang}/{file}` at runtime.

## Adding a language later

1. Add one value to `AppLanguage` in `lib/models/language.dart`.
2. Add `assets/audio/{code}/` with the same filenames and declare it in `pubspec.yaml`.
No content-JSON or screen changes needed.

## Adding a V2 module (Colors, Fruits)

1. Create `lib/data/{module}_content.json` (same shape as `abcd_content.json`).
2. Flip `locked: false` and set `contentPath` in `lib/services/content_loader.dart`.
3. Drop in images + audio.

## CI builds (GitHub Actions)

`.github/workflows/build.yml` runs on every push to `main`: analyze → test →
release APK + App Bundle, downloadable from the run's Artifacts.

One-time setup:

1. Create a GitHub repository and push this project:
   ```sh
   git remote add origin https://github.com/<you>/balgyan.git
   git push -u origin main
   ```
2. The first build works immediately (debug-signed APK — installable for testing).
3. For Play-Store-ready signing, create an upload keystore once:
   ```sh
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   base64 -i upload-keystore.jks | pbcopy
   ```
   then add repository secrets `ANDROID_KEYSTORE_BASE64` (pasted),
   `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`),
   `ANDROID_KEY_PASSWORD`. Local release builds can use the same keystore via
   `android/key.properties` (git-ignored; see `android/app/build.gradle.kts`).

## Privacy policy

`docs/privacy-policy.html` is the store-required policy page (the app collects
nothing; the page says so). To host it free with GitHub Pages: repository
Settings → Pages → Deploy from branch → `main` / `docs`. The URL becomes
`https://<you>.github.io/balgyan/privacy-policy.html` — paste that into the
Play Console listing.

## Before store submission

- Privacy policy URL must be live (see above).
- Google Play "Designed for Families" review: no ads, no non-approved SDKs,
  nothing collected from the child — this build satisfies all three (no network
  calls at runtime at all).
- The Parent Zone math gate doubles as the parental gate required for any
  future purchase flow.
