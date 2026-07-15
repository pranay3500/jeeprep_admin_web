# JEE Prep Admin Web — Progress & Pitfalls

> **Living log:** After each successful milestone, add a dated entry under **JEE integration log** below. Pair with `jeeprep_flutter/PROGRESS.md`.

## JEE integration log

| Date | Step | Status | Notes |
|------|------|--------|-------|
| 2026-06-08 | Admin login live | **Done** | https://jeeappadmin.satlas.org/ → `jee-prep-app-16bd5`; CDN cache-bust in `flutter_bootstrap.js` |
| 2026-06-08 | Firebase Auth (Console) | **Done** | Email/Password, user, authorized domains |
| 2026-06-08 | Web app registration | **Done** | Matches `lib/firebase_options.dart` |
| 2026-06-08 | Mobile `google-services.json` | **Done** | User replaced file → `jee-prep-app-16bd5` (verified by mobile `configure_jee_android_firebase.ps1`) |
| 2026-06-08 | Connectivity check | **Pass** | `tool/firebase_connection_check.ps1` — API OK; CMS docs missing until seed |
| 2026-06-08 | Firestore rules deploy | **Done** | `pranay3500@gmail.com` CLI; `firestore:rules` deployed to `jee-prep-app-16bd5` |
| 2026-06-08 | Tier 3–4 admin code | **Done** | `jee_main`, JEE CL API default, JEE Updates labels |
| 2026-06-08 | TPK JEE web icon | **Done** | `assets/icon/app_icon.png`; `flutter_launcher_icons` → `web/favicon.png` + `web/icons/*`; manifest green theme |
| 2026-06-09 | Favicon live check | **Pending deploy** | Source/build = 648 B green TPK; live `favicon.png` still 2086 B (Jun 8 upload). Rebuild done — upload `build/web/` + purge CDN |
| 2026-06-09 | CMS seed (Tier 2) | **Done** | `jeeprep_flutter/tool/seed_jee_cms.mjs` — 6 minimum docs in `jee-prep-app-16bd5` |
| 2026-06-10 | Firestore databaseId fix | **Done** | Admin `firestore_db.dart` + `firebase.json` → `(default)`; fixes save timeout + app sync |
| 2026-06-10 | JEE rebrand sweep | **Done** | CMS defaults, nav titles, courses/webinars/timeline templates, settings/email copy → JEE |
| 2026-06-10 | Exam Date permission-denied | **Fixed** | Root cause: old admin used Firestore DB `default` (NEET); JEE uses `(default)`. Rules re-released to `(default)` DB |
| 2026-06-10 | Users nav unread dot | **Done** | Mobile signup sets `users.adminUnread`; admin nav red dot on **Users**; clears when Users page opens |
| 2026-07-15 | Admin → user messaging | **Done** | Messages **New message** + Users mail icon → compose dialog (`admin_compose_user_message.dart`). Creates outreach thread for selected user. Rebuild/upload admin web to ship. JEE FCM CF pending Blaze on `jee-prep-app-16bd5` (in-app notif works now). |
| 2026-07-09 | Users unread red-dot hardening | **Done** | Matched NEET admin behavior: post-frame auto-ack + optimistic UI clear + batched `adminUnread=false` with timeout and audit fields (`adminSeenAt`, `updatedAt`, `updatedBy`) to prevent sticky Users badge/highlight. |
| 2026-07-09 | Eligibility logic rebase to DASA/CIWG | **In Progress** | `eligibility_tool_page.dart` default rule IDs/messages moved from legacy NEET/NRI flags to DASA/CIWG flags (R1–R9 + CIWG double-tag advisory). Default logic JSON now models DASA 2026 cutoff/score/CIWG-country configuration and severity buckets consumed by JEE app checker. |
| 2026-06-10 | Search engine blocking | **Done** | `web/robots.txt` (Disallow all), `index.html` meta robots, `.htaccess` `X-Robots-Tag` for jeeappadmin.satlas.org |
| | Rebuild + upload admin | **Optional** | If pulling latest JEE branding strings |

> **JEE clone status (2026-06-08):** Source + live admin on **`jee-prep-app-16bd5`**. Owner UID `GR9UjlgW4bVMIgCeFovzKhX1UGs1`.

## Update — 2026-06-08 (Admin login — wrong Firebase project on live server)

- **Root cause:** Network tab on live `jeeappadmin.satlas.org` showed Auth/Firestore calling **`testprepkart-jee-prep`** (`CONFIGURATION_NOT_FOUND` / 400). User Console only has **`jee-prep-app-16bd5`** + NEET — password reset in JEE project was correct; **uploaded `build/web` was wrong**.
- **Source audit:** `lib/firebase_options.dart`, `.firebaserc`, `firebase.json`, `admin_auth_constants.dart`, `admin_email_config.dart` already point at `jee-prep-app-16bd5` / `jeeappadmin.satlas.org`.
- **Fixed:** NEET URLs in `README.md`, `build_admin_daily.bat`, `tool/build_admin_web.ps1`, `deploy/email_relay/README.md`; build verification in `deploy_admin.ps1` + `tool/build_admin_web.ps1` (rejects `testprepkart-jee-prep` / `neet-prep-app-fc7fa` in `main.dart.js`).
- **Pending:** Run `deploy_admin.ps1` → upload **all** of `build/web/` → hard refresh → sign in with user from **JEE Prep App** (`jee-prep-app-16bd5`) Authentication. Add authorized domain `jeeappadmin.satlas.org` if missing. Deploy `jeeprep_flutter/firestore.rules` to same project.

## Update — 2026-06-08 (CDN cache — not upload failure)

- **Root cause (confirmed):** Origin `main.dart.js` on Satlas is correct (4,952,499 B, `jee-prep-app-16bd5`). **Cloudflare CDN** still serves stale `main.dart.js` (4,952,200 B, `testprepkart-jee-prep`) at the bare URL. `mainn.dart.js` worked because that URL was not cached. `main.dart.js?cachebuster` also returns the new file.
- **Fix:** Purge Cloudflare cache for `jeeappadmin.satlas.org` (Hostinger hPanel → Cloudflare → Purge). Build script now appends `?v=<buildId>` to `mainJsPath` in `flutter_bootstrap.js` so future deploys bypass CDN stale `main.dart.js`.
- **Cleanup:** Delete `mainn.dart.js` on server after purge.

## Update — 2026-06-08 (JEE_PARALLEL_CHECKLIST Tier 3–4 admin code)

- **JEE product constants:** `lib/src/jee_product_constants.dart` (`jee_main`, `jee/jee-planning`, JEE Updates label)
- **Exam Date CMS:** `exam_date_cms_page.dart` → `cms_exam_date/jee_main`
- **CL Import:** default API URL → JEE tree; **Updates/Settings/email** → “JEE Updates” branding
- **Banner targets:** JEE labels in `dashboard_banner_targets.dart`
- **Pending:** Rebuild + upload admin after pull; seed `cms_exam_date/jee_main` in admin UI

Tracks admin-only work so sessions do not re-debug the same issues. Pair with mobile app `jeeprep_flutter/PROGRESS.md` for end-to-end Content Library flow.

## Content architecture (do not confuse APIs)

| Layer | Source | Used by |
|--------|--------|---------|
| **Tree (API 1)** | `GET …/self-study/api/tree/content/neet/neet-planning` | CL Import → Firestore `content_library_import_nodes`; mobile library index |
| **Body (CMS)** | Admin CKEditor → **Publish** | Firestore `content_library_published_nodes/{websiteNodeId}` — fields `contentSource`, `status: "published"` |
| **Body (fallback API 2)** | `GET …/self-study/api/content/{nodeId}` | Mobile + **CL Editor preload** when Firestore empty |
| **PDF URLs** | Admin CL Import hierarchy | Firestore `cms_content_library/main` → `nodePdfUrls` |
| **Lock / free** | Admin CL Import | `cms_content_library/main` gating lists |

Mobile read order for section HTML: **published Firestore** → cache → **API 2**.

---

## Update — 2026-06-05 (Seat Allotment — v1 complete + Mobile Bundle tab)

- **Current status:** MBBS Seats **v1 feature-complete on mobile** (bundled SQLite + local agent; no Claude). Admin **Seat Allotment** has tabs **CSV Import** / **Datasets** / **Mobile Bundle**.
- **Mobile Bundle tab:** Live read of Firestore `cms_seat_allotment/main` — published flag, fingerprint, version, Storage paths, last write. Explains CSV datasets = admin QA only; mobile reads bundled/OTA SQLite.
- **Mobile polish:** Counseling Ask inline result previews → detail sheet (`seat_allotment_counseling_ask_screen.dart`).
- **Publish (optional OTA):** CLI only — see Mobile Bundle tab or `neetprep_flutter/PROGRESS.md` § Optional. Rules: `powershell -File tool/deploy_seat_allotment_rules.ps1`.
- **Files changed:**
  - `lib/src/pages/seat_allotment_page.dart` (Mobile Bundle tab)
  - `neetprep_flutter/lib/features/mbbs_seats/seat_allotment_counseling_ask_screen.dart`
  - `neetprep_flutter/tool/deploy_seat_allotment_rules.ps1`
- **Optional (not blocking v1):**
  - [ ] Deploy seat-allotment Firestore + Storage rules + first bundle publish (OTA)
  - [ ] Rebuild + upload admin web (`build_admin_daily.bat`) so Mobile Bundle tab is live
  - [ ] Claude / `counselingInsightSummarize` (deferred)

---

## Update — 2026-06-03 (Seat Allotment CMS + CSV import)

- **Current status:** Admin nav **Seat Allotment** with tabs **CSV Import** / **Datasets** / **Mobile Bundle**; CSV → Firestore for admin QA; mobile uses SQLite bundle/OTA (see Mobile Bundle tab).
- **Nav:** Left rail **Seat Allotment** (index 10); shifted Courses/Webinar/Settings/Unsubscribe/Users to 11–15.
- **Firestore:**
  - `seat_allotment_datasets/{datasetId}` — metadata, `isPublished`, `filterOptions`, `rowCount`
  - `seat_allotment_datasets/{datasetId}/rows/{rank_serialNo}` — allotment rows
- **Rules:** `neetprep_flutter/firestore.rules` — `seat_allotment_datasets` public read when `isPublished`; `cms_seat_allotment` public read; admin write via `isContentAdmin()`.
- **Files changed:**
  - `lib/src/pages/seat_allotment_page.dart`
  - `lib/src/seat_allotment/seat_allotment_csv.dart`
  - `lib/src/seat_allotment/seat_allotment_import_service.dart`
  - `lib/src/utils/csv_file_pick_web.dart`
  - `lib/src/admin_app.dart`
- **Historical note:** Mobile no longer reads `seat_allotment_datasets` rows — it uses bundled/OTA SQLite (see 2026-06-05 update).
- **22k+ rows:** Do not use browser import — use CLI `neetprep_flutter/tool/import_seat_allotment_csv.mjs` + service account JSON (see script header). Admin web is for small files / publish toggle only.
- **Fix (2026-06-03):** `permission-denied` on import — Firestore rules reordered (`isContentAdmin()` before `get(parent)`); import creates dataset doc before row deletes; rules deployed (`firebase deploy --only firestore:rules`).
- **Local admin run:** Double-click **`start admin app.bat`** or `powershell -File tool\run_admin_web.ps1` (opens **Chrome**). **`start admin app.bat` no longer uses `web-server`.** If terminal shows `Terminate batch job (Y/N)?`, you pressed Ctrl+C — press **Y**, restart. Optional manual URL mode: `start admin app (web-server).bat` then http://127.0.0.1:8081.

---

## Update — 2026-06-02 (Public account deletion URL + admin queue)

- **Current status:** Google Play–compliant public page and admin review queue implemented.
- **Public URL (user-facing, recommended):** upload `deploy/testprepkart_unsubscribe/index.html` → `https://www.testprepkart.com/unsubscribe/` (standalone HTML; not the admin Flutter build).
- **Public URL (admin host, optional):** `https://neetappadmin.satlas.org/unsubscribe` — requires `web/.htaccess` SPA rewrite in deployed `build/web/` so the URL does not redirect to `/`.
- **Admin menu:** **Unsubscribe** (nav index 13) — table of requests with status + unread badge.
- **Files changed:**
  - `lib/main.dart` (`usePathUrlStrategy` for `/unsubscribe` path)
  - `lib/src/admin_app.dart` (route gate, nav)
  - `lib/src/pages/unsubscribe_page.dart`
  - `lib/src/pages/unsubscribe_requests_page.dart`
  - `lib/src/services/account_deletion_request_service.dart`
  - `../neetprep_flutter/firestore.rules` (`account_deletion_requests` collection)
- **Pending cleanup:**
  - Deploy Firestore rules: `firebase deploy --only firestore:rules` from `neetprep_flutter` or admin `firebase.json` path.
  - Rebuild + upload admin `build/web/` via `deploy_admin.ps1`.
  - Ensure Satlas serves `index.html` for `/unsubscribe` (SPA fallback), not a static 404.
  - Play Console **Delete account URL:** `https://www.testprepkart.com/unsubscribe/`
  - Firebase **Authorized domains:** add `testprepkart.com` and `www.testprepkart.com`
  - Standalone upload package: `deploy/testprepkart_unsubscribe/`
  - Actual account deletion remains manual (Firebase Auth / App Users) when status = Completed.

---

## Local admin web dev (May 25, 2026)

- **Files:** `tool/flutter_sdk.path`, `tool/flutter_env.ps1`, `tool/run_admin_web.ps1`, `.cursor/rules/flutter-sdk-path.mdc`
- **Flutter SDK (machine):** `E:\New_TPK_2026\Apps\NEET_Flutter_App\SDK\flutter` — stored in `tool/flutter_sdk.path` (do not re-prompt).
- **Folder:** `neetprep_admin_web` (not `neetprep_flutter`).
- **Run:** `powershell -File tool/run_admin_web.ps1` (uses SDK from `tool/flutter_sdk.path`).
- **Release build:** `powershell -File tool/build_admin_web.ps1` → deploy `build/web/` (must run from `neetprep_admin_web`, not `C:\Users\prana`).
- **Avoid** `flutter run -d web-server` unless you manually open **http://127.0.0.1:8081** — it does not launch a browser; “Waiting for debug service” can sit for 45s+ while the server is already up.
- **Firebase Auth → Authorized domains:** add **`localhost` and `127.0.0.1`** (Chrome/`flutter run` often uses `http://127.0.0.1:PORT`, not `localhost`).
- **Sign-in not showing:** fixed May 25 — `AdminAuthGate` no longer blocks on auth-stream spinner; shows `SignInPage` immediately when signed out. If stuck on “Checking admin access”, use **Sign out**. Hot restart after pull: `R` in terminal or re-run `tool/run_admin_web.ps1`.
- **Console `Firestore probe permission-denied`:** fixed — startup probe reads public `cms_dashboard/main` (not `_admin_connectivity_probe`, which requires sign-in).
- **Blank admin shell after login (May 25):** Replaced `NavigationRail` + `SingleChildScrollView` (unbounded height / Expanded conflict on web) with scrollable `ListView` side nav (`_AdminNavigationRail`). Removed nested `Scaffold` in `demo_request_page.dart`.
- **TestprepKart logo (May 29, 2026):** `assets/images/testprepkart_logo.png` + `TestprepKartLogo` widget — top-left on signed-in `AppBar` and sign-in screen.
- **Blank page:** check browser DevTools Console; confirm `lib/firebase_options.dart` exists.

---

## App moderators — panel access (May 25, 2026)

- [x] **App Users** (`users_page.dart`): owner grants **Grant moderator** / **Revoke**; filters for panel vs app users; instructions card.
- [x] **Subscription requests (May 29, 2026):** Red dot on user row when `subscriptionRequestPending`; filter chip **Subscription requests**; owner tap request icon to approve paid user (`isPremium: true`) and clear pending, with secondary action to mark handled-only. Users nav badge when pending requests exist. Mobile writes flag via `subscription_requests` + user merge (deploy `firestore:default:rules`).
- [x] **Reset subscription (May 29, 2026):** Owner **Reset** on Users table — clears `isPremium`, `subscriptionExpiry`, pending request flags; user returns to free on next app sync.
- [x] **Users table UX (May 29, 2026):** **Date** first column; **Class** column (`grade` / `currentGrade`); subscription + admin actions as compact icons (request / premium / free + reset, grant/revoke); **From/To** date filters; **Export CSV** for filtered rows. Files: `users_page.dart`, `utils/csv_download_web.dart`.
- [x] **Sign-in:** Moderators use the **same email/password** as the mobile app after owner grants `role: moderator` on their `users/{uid}` doc.
- [x] **Owner-only UI:** `AdminSession.isOwner` — only `pranay3500@gmail.com` / owner UID can grant/revoke; moderators see read-only access column.
- [x] **Firestore rules:** `isPanelModerator()` + `isContentAdmin()` in `neetprep_flutter/firestore.rules` (deploy `firestore:default:rules`). Owner-only writes: `admin_settings`, user role grants.

---

## Admin web email (no Blaze) — May 21, 2026

- [x] **Architecture:** Firestore → admin web listeners (while signed in) → HTTP **email relay** on Satlas → Hostinger SMTP.
- [x] **Relay:** `deploy/email_relay/server.js` — deploy beside admin static site; URL in Settings → **Email Relay URL**.
- [x] **Triggers:** All Settings toggles + `userRegistered` welcome email; dedupe in `admin_email_sent/{key}`; logs in `email_dispatch_logs`.
- [x] **Confirm demo:** Sends immediately from admin via `AdminEmailDispatcher` (not Cloud Functions).
- **Deploy relay on Satlas** (required once): see `deploy/email_relay/README.md`
- **Deploy rules:** `firebase deploy --only firestore:rules` from `neetprep_flutter`
- **Note:** Admin tab must stay open for automatic Firestore-triggered emails (new user, message, inquiry, etc.).

---

## Admin edit dialogs — Save vs Save & Close (May 21, 2026)

- [x] **Save** keeps the popup open; **Save & Close** saves and dismisses.
- **Widget:** `lib/src/widgets/admin_dialog_save_actions.dart`
- **Applied:** Courses, Medical Colleges, Updates, Timeline, How It Works, Support FAQ, Slots (Create), Analysis reschedule/report, Settings email template + FAQ, CL Import PDF URL.

---

## Webinars CMS (May 21, 2026)

- [x] **Webinar** nav tab — create/edit webinars for mobile home + detail pages.
- [x] **Edit fix:** Loads full document by ID on edit (not stale list snapshot); list query without `orderBy` + client sort (docs missing `scheduledAt` no longer break the list).
- [x] **Thumbnail:** `thumbnailImageUrl` + optional `heroImageUrl` for mobile card/detail hero.
- [x] **Nav UI:** `Scaffold` → `Expanded` → `Row` → scrollable `NavigationRail` + `Expanded(page)` (fixes bottom overflow on Settings/Users when viewport is short). Badge streams only on `_AdminNavigationRail`.
- [x] **Demo Request page:** wrapped in inner `Scaffold` so `TabBar`/`TabBarView` get height.
- [x] **Sample analysis report PDFs (May 25, 2026):** `demo_request_page.dart` — `sampleReports` field (`title | HTTPS PDF URL`) saved to `demo_request_config/expected_score`; mobile Expected NEET Score → Sample reports opens URLs in-app.
- **Login:** `SignInPage` when not signed in; use app bar **Sign out** to return to login. First tab title is **Demo Request** by design (not a missing dashboard).
- [x] **Schedule (IST → US):** **Pick IST** date/time; saves UTC `scheduledAt` + auto `timezoneDisplay` (Eastern/Pacific, DST). Read-only US preview in form; list shows IST + US lines. Dep: `timezone` ^0.9.4; init in `main.dart`.
- [x] Fields: duration, highlights, HTML, join URL (premium in app), recordings, assets, session recording.
- [x] **Empty Firestore:** `Publish default webinar` seeds `webinars/default_featured_webinar` (same content mobile preview used). App no longer shows placeholder without Firestore.
- [x] **Disable / enable (May 29, 2026):** List row **Disable** / **Enable** buttons set `isPublished: false` / `true` (confirm before disable). **Visible in app** chip vs session status chip (Upcoming/Live/Past). Mobile `WebinarRepository.watchPublished()` already filters unpublished docs.
- **Files:** `lib/src/pages/webinars_cms_page.dart`, `lib/src/utils/webinar_schedule_timezone.dart`, `lib/main.dart`, `lib/src/admin_app.dart`

---

## Courses CMS — course detail fields (May 21, 2026)

- [x] **Pricing:** INR current/original only; USD auto on save via `lib/src/services/exchange_rate_service.dart`.
- [x] **Course edit:** HTML content, class videos (4 lines), coupon, enrollment/bank/brochure/payment bodies, feature icons (`title | description | icon`).
- [x] **YouTube:** Video ID normalized from full URL on save (page settings + course video).
- **File:** `lib/src/pages/courses_cms_page.dart`

---

## Admin Messages — mark as read (May 21, 2026)

- [x] Yellow row (`adminUnread`) clears via **Mark as read** icon (envelope) next to View — no reply required.
- **File:** `lib/src/pages/messages_page.dart`

---

## Admin sign-in security (May 21, 2026)

- [x] **Captcha** on sign-in and forgot-password (`AdminCaptchaField` — math challenge).
- [x] **Lockout:** after 3 failed attempts, block sign-in for 60 minutes (`admin_login_security/{emailKey}` in Firestore). **Temporarily off** for local: `AdminAuthConstants.loginLockoutEnabled = false` — set `true` before production.
- [x] **Forgot password:** only sends reset email if email is owner or active admin/moderator in Firestore (no `fetchSignInMethodsForEmail` — broken under enumeration protection).
- [x] **Sign-in fix (May 21):** `AdminAuthEligibility` no longer uses deprecated `fetchSignInMethodsForEmail` (returned empty → false “invalid password” after reset). Post-login gate uses email + `users/{uid}` fallback.
- [x] **Firestore rules** for `admin_login_security` in `neetprep_flutter/firestore.rules` — deploy with `firebase deploy --only firestore:rules`.
- **Files:** `sign_in_page.dart`, `forgot_password_page.dart`, `admin_login_security_service.dart`, `admin_auth_eligibility.dart`, `admin_auth_constants.dart`, `admin_captcha_field.dart`.

---

## Live deployment (May 21, 2026)

- **Production URL:** [https://neetappadmin.satlas.org/](https://neetappadmin.satlas.org/)
- **Firebase project:** `neet-prep-app-fc7fa` (`lib/firebase_options.dart`)
- [x] Email Functions admin links point at live URL (`neetprep_flutter/functions/index.js` → `ADMIN_WEB_BASE_URL`).
- [ ] **Firebase Console:** Authorized domain `neetappadmin.satlas.org`
- [ ] **CORS:** Allow live admin origin on TestprepKart CL APIs if browser import fails
- **Local dev (unchanged):** `run_admin.ps1` / `127.0.0.1:8081` for debugging only
- [x] **Connectivity test (May 21):** `neetprep_flutter/tool/firebase_connection_check.ps1` — admin URL 200; same Firestore CMS docs readable as mobile.
- **Verify:** Sign in on live URL → edit Settings or CL → Publish → mobile Production reflects change

---

## Current workstream

### Home dashboard banners (May 16, 2026)

- [x] **Settings → Home Banners:** Publish up to 5 carousel images; set required design width/height (px) and auto-scroll interval; enable/disable carousel.
- [x] **Banner preview on web (May 25, 2026):** `AdminCorsNetworkImage` uses `WebHtmlElementStrategy.prefer` so CDN URLs (e.g. `data.testprepkart.com`) preview in admin without CORS `statusCode: 0` (mobile app was unaffected).
- [x] **Banner in-app tap targets (May 25, 2026):** Admin **On tap** → website or app screen (`linkType` + `appRoute` on Firestore); mobile `DashboardBannerNavigation` opens tabs/screens.
- [x] **Banner form persistence (May 25, 2026):** Wait for Firestore before hydrating; re-load saved URLs when returning to Home Banners tab (fixed one-shot `_loaded` applying placeholders on first empty snapshot).
- **Firestore:** `cms_dashboard/main`
- **Files:** `lib/src/pages/dashboard_banners_settings_tab.dart`, `lib/src/widgets/admin_cors_network_image.dart`

### CL Editor — CKEditor container `tpk-ck-0` not found (May 16, 2026)

**Symptom:** Red error `CKEditor container not found: tpk-ck-0`, blank editor (e.g. Stage 1).

**Cause:** `ckeditor_bridge.js` called `document.getElementById` immediately after `HtmlElementView` `onPlatformViewCreated`. Flutter web platform views mount the host `div` asynchronously; DOM id `tpk-ck-{viewId}` may not exist yet.

**Fix applied:**

- `web/ckeditor_bridge.js` — `waitForElement()` polls with `requestAnimationFrame` (up to 15s) before `ClassicEditor.create`.
- `lib/src/widgets/ckeditor/content_library_ckeditor_web.dart` — 80ms delay before `create`; guard stale `viewId` if widget disposed/remounted.
- `lib/src/pages/content_library_editor_page.dart` — mount CKEditor only after `_loadingDoc == false`; `ValueKey('$_selectedWebsiteId-$_editorMountGeneration')` bumps after each load (not `hashCode` on HTML).

**Verify:** Run admin on web (`flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081`). Open CL Editor → Stage 1 → toolbar visible, content editable → Publish → mobile shows Firestore body.

**If it regresses:** Hard refresh (Ctrl+Shift+R) so `ckeditor_bridge.js` is not cached; confirm `index.html` loads bridge after CKEditor CDN.

### CL Editor — blank when Firestore empty (May 16, 2026)

- [x] Preload from **API 2** when published doc missing or `contentSource` empty.
- **Files:** `content_library_editor_page.dart`, `content_library_remote_content_service.dart`, `content_library_published_service.dart`.

### CL Import — PDF per node (May 16, 2026)

- [x] PDF icon on hierarchy rows; URLs stored in `cms_content_library/main` → `nodePdfUrls`.
- **File:** `content_library_import_page.dart`.

---

## Known pitfalls

1. **Container timing** — Never call CKEditor `create` without waiting for `tpk-ck-{viewId}` in DOM (see above).
2. **Editor before load** — Do not mount `ContentLibraryHtmlEditor` while `_loadingDoc`; controller must have HTML before `create`.
3. **API 1 vs 2** — Tree import does not populate editor body; only API 2 or Firestore publish does.
4. **Web cache** — JS bridge changes need full browser refresh, not only Flutter hot reload.

---

## Analysis demo slots (May 29, 2026)

- [x] **Slots tab** (`slots_management_page.dart`): IST-based create/list (matches mobile session date), quick-add panel + time presets, day filter, save/error snackbars, delete confirm; `AdminDialogSaveActions` shows Firestore exceptions.
- [x] **Timezone helper:** `WebinarScheduleTimezone.istDayUtcRangeFromWall` for admin + mobile day queries.
- [x] **Nav badge:** Left menu **Demo Request** red dot when any `analysis_session_requests` has `status == pending_confirmation` (same as mobile booking); **Demo Requests** tab shows “· new” + badge icon.
- [x] **Recurring demo slots (May 29, 2026):** Admin **Slots** tab uses `analysis_slot_templates` (IST time only, no date). App books **IST tomorrow** only; timezone picker + labels like `9:30 PM CST (8:00 AM IST)`. Deploy `firestore.rules` for `analysis_slot_templates`.
- **Test:** Demo Request → Slots → create slot 2–7 days ahead (IST) → mobile **production** (Guest off) → Expected Score → Schedule → pick same IST date → refresh slots icon.

---

## Files (Content Library admin)

| Area | Path |
|------|------|
| Editor page | `lib/src/pages/content_library_editor_page.dart` |
| Import + PDF | `lib/src/pages/content_library_import_page.dart` |
| CKEditor widget | `lib/src/widgets/ckeditor/content_library_ckeditor_web.dart` |
| JS bridge | `web/ckeditor_bridge.js` |
| API 2 preload | `lib/src/content_library/content_library_remote_content_service.dart` |
| Publish save | `lib/src/content_library/content_library_published_service.dart` |
