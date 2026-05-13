# Installing IWBF Team Points Control on Android

This guide explains how to obtain the release APK and install it on a real
Android device or on a cloud device farm (BrowserStack, Firebase Test Lab,
AWS Device Farm). The app is distributed as a sideloaded `.apk` — there is
no Google Play release.

## 1. Download the release APK

The release build is produced automatically by GitHub Actions every time a
commit lands on `main` or on a `claude/*` development branch.

1. Open the repository on GitHub: `gnpazinato/iwbf-team-points-control`.
2. Go to **Actions → Build Android APK**.
3. Pick the run for the commit you want.
4. Scroll to the **Artifacts** section and download
   `iwbf-team-points-control-apk` (zipped).
5. Unzip — you get `app-release.apk`.

If the workflow has not run for the desired commit yet, push the branch
again or trigger **Run workflow** manually.

## 2. Install on a physical Android tablet (recommended)

Tested on Samsung Galaxy Tab A9+ and Tab S9 FE (Android 13 / 14).

1. Copy `app-release.apk` to the tablet (USB cable, Google Drive, email
   attachment, etc.).
2. On the tablet, open the file. Android will warn that the app comes from
   an unknown source.
3. If installation is blocked, go to **Settings → Apps → Special app
   access → Install unknown apps** and allow the source (Files, Drive,
   browser) to install APKs.
4. Tap **Install**. After the installation finishes, open **IWBF Team
   Points Control**.

> The exact menu path varies a little between Android versions and OEM
> skins. On Samsung One UI the path above is correct; on stock Android 14
> the option is under **Settings → Apps → Special access**.

## 3. Install on a cloud device (BrowserStack / Firebase Test Lab)

### 3.1 BrowserStack App Live

1. Sign in at <https://app-live.browserstack.com/>.
2. Upload `app-release.apk` (drag & drop or "Upload App").
3. Pick a tablet profile (e.g., Galaxy Tab S9, Pixel Tablet) or a phone
   profile (e.g., Galaxy S24).
4. The app launches automatically.

### 3.2 Firebase Test Lab — manual install via `gcloud`

1. Install the gcloud CLI and authenticate (`gcloud auth login`).
2. Upload the APK and start a Robo test:
   ```bash
   gcloud firebase test android run \
     --type=robo \
     --app=app-release.apk \
     --device=model=oriole,version=33,locale=en,orientation=portrait
   ```
3. Pick a tablet model (e.g., `tangorpro` for Pixel Tablet) and a phone
   model (e.g., `oriole` for Pixel 6) and run the command for both.

### 3.3 AWS Device Farm

1. Create a new project (one-time setup).
2. Upload `app-release.apk` as the test target.
3. Create a Device Pool with a tablet (e.g., Galaxy Tab S9) and a phone
   (e.g., Galaxy S24).
4. Start a remote access session — the app installs and runs.

## 4. First-run sanity checklist on the device

Once the app starts, validate the golden path manually:

1. The home screen shows the IWBF logo, the title and three buttons:
   *Load Reference Spreadsheet*, *Download Template — Single Sheet*,
   *Download Template — One Sheet per Team*.
2. Tap **Download Template — Single Sheet**. The snackbar should show the
   path where the template was saved.
3. Tap **Load Reference Spreadsheet** and pick the template that was just
   saved. The validation summary should show *Spreadsheet loaded
   successfully.* with 2 teams / 4 players.
4. Continue → **Match Setup**. Pick Brazil as Team A, Argentina as Team B,
   keep Point Limit at 14.0. Tap **Start Match**.
5. On the lineup screen, tap five players in Team A. Confirm that the
   total updates, that the players appear on the rotated court image with
   the IWBF jersey icon, and that selecting a 6th player shows the
   snackbar *Only 5 players can be selected for Team A.*.
6. Switch Point Limit to 13.0 (drop down). The alert *Point limit
   exceeded.* should appear in red and the device should vibrate once.
7. Tap **Change Teams**, confirm. You should return to Match Setup with
   the same loaded spreadsheet.

If anything in steps 1–7 fails, capture a screenshot and file an issue on
GitHub.

## 5. Uninstalling

Tap and hold the app icon → **Uninstall**. The local cache (current
selection, point limit, loaded teams) is removed automatically.

## 6. Permissions used

The app requires:

- **Storage** access only when saving downloaded templates and reading the
  reference spreadsheet picked by the user. No background storage access.
- **Vibration** — for the one-time short buzz when the team total crosses
  the configured point limit.
- **Wake lock** — to keep the screen on during the match (no other
  background work happens).

No network permission is requested. The app runs fully offline.
