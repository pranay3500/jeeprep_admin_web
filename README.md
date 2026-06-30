# jeeprep_admin_web

Flutter admin CMS for **TestprepKart JEE Prep** (separate from NEET).

- **GitHub:** https://github.com/pranay3500/jeeprep_admin_web
- **Live URL:** https://jeeappadmin.satlas.org/
- **Firebase project:** `jee-prep-app-16bd5` (see `lib/firebase_options.dart`)
- **Mobile app repo:** https://github.com/pranay3500/jeeprep_flutter (Firestore rules + indexes)

## Running locally

```powershell
cd "e:\New_TPK_2026\Apps\jeeprep_admin_web"
powershell -File tool\run_admin_web.ps1
```

Or double-click `start admin app.bat`.

Add `localhost` and `127.0.0.1` under Firebase Console → Authentication → Authorized domains for local sign-in.

## Deploy to live server

Local code is **not** synced automatically. Each release: **build on PC → upload `build/web` → replace old files on Satlas**.

### 1. Build

```powershell
cd "e:\New_TPK_2026\Apps\jeeprep_admin_web"
powershell -ExecutionPolicy Bypass -File .\deploy_admin.ps1
```

Output: **`build/web/`** — upload the **entire folder** to the document root for `jeeappadmin.satlas.org`.

The build script verifies `main.dart.js` contains `jee-prep-app-16bd5` and rejects wrong Firebase projects before you upload.

### 2. Upload to Satlas

Use FTP / file manager / SCP — same method as your first deploy. Upload **all** files from `build/web/`.

### 3. Verify

1. Open https://jeeappadmin.satlas.org/
2. Hard refresh: **Ctrl+Shift+R**
3. Sign-in footer must show Firebase project: **jee-prep-app-16bd5**
4. DevTools → Network → sign in → `signInWithPassword` must **not** call `testprepkart-jee-prep`

### Firebase Console (`jee-prep-app-16bd5`)

- Authentication → Sign-in method → **Email/Password** enabled
- Authentication → Authorized domains → **jeeappadmin.satlas.org**
- Deploy rules from `jeeprep_flutter`: `firebase deploy --only firestore:rules --project jee-prep-app-16bd5`

### Email relay (optional)

Deploy `deploy/email_relay` on Satlas; set URL in admin Settings. See `deploy/email_relay/README.md`.
