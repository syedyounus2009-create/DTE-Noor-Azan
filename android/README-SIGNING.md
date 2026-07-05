# Signing the Noor APK

## Right now, with zero setup

`flutter build apk --release` (locally or via the included GitHub Actions
workflow) already works with **no signing setup at all** — `app/build.gradle`
falls back to the Android debug keystore when no release signing config is
found. That produces a real, installable `.apk` you can side-load onto any
Android phone (Settings → install from unknown sources) or share directly.
This is enough to test with, use privately, or distribute outside the Play
Store.

**Debug-signed ≠ Play Store eligible.** Google Play requires a real release
key. Do the steps below only when you're ready to publish.

## Generating a real release key (one-time)

```bash
keytool -genkey -v -keystore noor-release.keystore \
  -alias noor -keyalg RSA -keysize 2048 -validity 10000
```

Keep `noor-release.keystore` and its passwords somewhere safe — losing it
means you can never publish an update to the same Play Store listing again.

## Option A — build locally with the real key

Create `android/key.properties` (already gitignored, never commit it):

```properties
storeFile=/absolute/path/to/noor-release.keystore
storePassword=your-store-password
keyAlias=noor
keyPassword=your-key-password
```

Then `flutter build apk --release` automatically picks it up.

## Option B — build in CI with the real key (recommended)

1. Base64-encode the keystore: `base64 -i noor-release.keystore | pbcopy`
   (or `base64 -w0 noor-release.keystore` on Linux).
2. In your GitHub repo → Settings → Secrets and variables → Actions, add:
   - `NOOR_KEYSTORE_BASE64` — the base64 string from step 1
   - `NOOR_KEYSTORE_PASSWORD`
   - `NOOR_KEY_ALIAS`
   - `NOOR_KEY_PASSWORD`
3. Push to `main` (or run the workflow manually). The included
   `.github/workflows/build-apk.yml` decodes the keystore, signs the
   release build with it, and uploads `app-release.apk` as a downloadable
   artifact on the run page — no local Flutter/Android install needed on
   your machine at all.

## Publishing to Google Play

Once you have a real-signed APK/AAB, follow Play Console's own upload flow
(App bundle explorer → Production/Internal testing track). `flutter build
appbundle --release` produces the `.aab` Play prefers over a raw APK.
