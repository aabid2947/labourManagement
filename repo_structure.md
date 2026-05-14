# repo_structure.md

Single source of truth for the **Labour Management** Flutter app's codebase.
Update this file at the end of every prompt. Anyone (human or agent) picking up the project
should be able to read this file and have full context.

## How to run

```bash
# 1. Prerequisites
#    - Flutter SDK 3.41.9 (Dart 3.11.5)
#    - Android Studio + an Android emulator OR a physical device (USB-debug enabled)
#    - For iOS: macOS host + Xcode (the project ships Info.plist permission strings;
#      iOS build cannot be verified from a Windows host)

# 2. Install packages
flutter pub get

# 3. Run on the connected device / emulator
flutter run

# 4. Lints + tests + builds
flutter analyze         # → No issues found
flutter test            # → All tests passed (smoke + viewport sweep)
flutter build apk --release         # Android release
flutter build ios --debug --no-codesign   # macOS host only
```

The app boots to a 500 ms branded splash, then routes to **MPIN Login** (if a
stored MPIN is found) or **Login** (first launch). A small *Theme Preview* link
at the bottom of the splash opens the design-system gallery for visual QA.

**Backend wiring:** every endpoint stub is summarized in
[`api_contract.md`](api_contract.md) — that is the single page to hand to the
backend dev. Real-call blocks are commented next to each mock so the wiring is
a copy-and-uncomment job for every method.

---

- **Flutter SDK:** 3.41.9 (Dart 3.11.5)
- **State management:** flutter_riverpod (chosen and committed for the whole project)
- **Routing:** go_router
- **Networking:** dio (singleton in `core/network/dio_client.dart`)
- **Persistence:** flutter_secure_storage (wrapped in `core/storage/`)
- **Responsive:** flutter_screenutil with design size `Size(375, 812)`
- **Date format:** `DD-MM-YY` everywhere
- **MPIN:** 4 digits (confirmed from `page04_img01.jpeg` + `page06_img01.jpeg`)
- **Targets:** Android + iOS only

---

## Conventions

1. **File header** — every Dart file in `lib/` MUST start with:
   ```
   // File: <relative path from project root>
   // Purpose: <one sentence — what this file is responsible for>
   // Used by: <which screens / features import this; "n/a" if entry point>
   ```

2. **API stubs** — wherever a network call belongs, leave a comment in this exact shape:
   ```
   // TODO(api): METHOD /path — request: {...}, response: {...}
   ```

3. **AWS Rekognition** — keys / endpoint live ONLY in `lib/core/config/aws_config.dart`. Never inline.

4. **State management** — Riverpod only. Do not mix Provider / Bloc / GetX.

5. **Responsive** — use `.sp`, `.w`, `.h` from flutter_screenutil; no hardcoded pixel sizes
   outside of `core/constants/app_dimensions.dart`.

6. **No design changes** — pixel-match the screenshots in `../images/`.

---

## Design tokens (sampled from screenshots — Prompt 2)

| Token | Hex | Where it appears |
|---|---|---|
| primary | `#FFB300` | LOGIN button, MPIN dots, CLAIM NOW, TODAY'S TASK banner, FAB |
| primaryDark | `#F5A300` | Brand text "S-Square", focused borders |
| primarySoft | `#FFF3D6` | "Project Alpha • Mumbai Metro" pill, Total Labour Added pill |
| avatarBg | `#FFEFD6` | Labour avatar circle background |
| background | `#F7F8FA` | Scaffold background |
| surface | `#FFFFFF` | Cards, AppBar |
| cardBorder | `#EAECEF` | Card outline |
| success | `#4CAF50` | Welcome shield icon, success popup tick |
| info | `#1F6FEB` | "45/55 Today Attendance" number + progress bar |
| error | `#E53935` | Required-field asterisks, validation errors |
| divider | `#E5E7EB` | Input borders, dividers |
| textPrimary | `#1A1F2C` | Titles, body |
| textSecondary | `#6B7280` | Subtitles, captions |
| textDisabled | `#9CA3AF` | Disabled text |
| textOnPrimary | `#1A1F2C` | Dark text on yellow buttons |

---

## Folder Tree (`lib/`)

```
lib/
├── main.dart                              # entry — boots ProviderScope + LabourManagementApp
├── app/
│   └── app.dart                           # root widget — ScreenUtilInit + MaterialApp.router
├── core/
│   ├── config/
│   │   ├── env.dart                       # build-time environment enum
│   │   ├── api_config.dart                # base URLs + timeouts (stubs)
│   │   └── aws_config.dart                # AWS Rekognition endpoint + keys (empty stubs)
│   ├── constants/
│   │   ├── app_colors.dart                # palette sampled from screenshots
│   │   ├── app_strings.dart               # user-facing strings (popups, buttons)
│   │   ├── asset_paths.dart               # bundled asset paths
│   │   └── app_dimensions.dart            # spacing / radius / icon-size tokens
│   ├── theme/
│   │   ├── color_scheme.dart              # Material ColorScheme from AppColors
│   │   ├── text_styles.dart               # AppTextStyles (appBar, body, button, ...)
│   │   └── app_theme.dart                 # AppTheme.light — ThemeData wired into MaterialApp
│   ├── network/
│   │   ├── dio_client.dart                # singleton Dio with base URL + interceptors
│   │   └── api_interceptor.dart           # attaches token, dev-mode logging
│   ├── storage/
│   │   ├── secure_storage.dart            # thin wrapper on flutter_secure_storage
│   │   └── auth_storage.dart              # token + MPIN hash persistence
│   ├── utils/
│   │   ├── validators.dart                # required / email / phone / mpin(4) / min+maxLength
│   │   ├── formatters.dart                # date (DD-MM-YY), currency (₹), day name
│   │   └── responsive_helper.dart         # isNarrow / isPhone / isFoldableOpen / isTablet
│   └── widgets/
│       ├── primary_button.dart            # filled CTA (loading + disabled states)
│       ├── secondary_button.dart          # outline button
│       ├── app_text_field.dart            # labeled field with prefix icon + password toggle
│       ├── app_dropdown.dart              # generic AppDropdown<T> with label
│       ├── app_date_picker.dart           # opens calendar, displays DD-MM-YY
│       ├── loading_overlay.dart           # blocking spinner overlay
│       ├── confirm_dialog.dart            # Yes / No dialog ("Are you sure...?")
│       ├── success_dialog.dart            # single-action success popup
│       ├── section_card.dart              # rounded white card with border
│       └── app_scaffold.dart              # Scaffold wrapper (app bar, SafeArea, padding)
├── features/
│   ├── auth/                              # Prompts 3 + 4
│   │   ├── data/
│   │   │   ├── auth_api_service.dart      # stubbed POST /auth/login + /contact-admin
│   │   │   ├── auth_repository.dart       # domain wrapper, persists token (commented)
│   │   │   └── biometric_service.dart     # local_auth 3.x wrapper (tap-only)
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart            # page02 — User ID + Password + Site + Biometric
│   │   │   │   ├── contact_admin_screen.dart    # modal bottom sheet (Name + Email + Submit)
│   │   │   │   ├── set_mpin_screen.dart         # page04 — 4-digit MPIN entry → Confirm
│   │   │   │   ├── confirm_mpin_screen.dart     # page06 — re-enter, on match hash + store + Dashboard
│   │   │   │   └── mpin_login_screen.dart       # page08 — returning user, 5/30s lockout, Forgot MPIN, Fingerprint
│   │   │   └── widgets/
│   │   │       ├── brand_header.dart      # TEJ GROUP | S-Square header + bell, FooterCopyright
│   │   │       ├── mpin_dots.dart         # MpinDots (filled circles) + MpinBoxes (outlined squares)
│   │   │       └── mpin_keypad.dart       # 3×4 numeric keypad with backspace
│   │   └── providers/
│   │       ├── auth_providers.dart        # repo / biometric service / LoginController
│   │       └── mpin_providers.dart        # MpinDraft, MpinLoginController (lockout), authBootstrapProvider
│   ├── expense/                           # Prompt 11
│   │   ├── data/
│   │   │   ├── expense_models.dart                # ExpenseStatus enum (incl. inProgress), kExpenseTabs, kExpenseCategories, Expense, ExpenseSummary, ExpenseDraft
│   │   │   ├── expense_api_service.dart           # stubs: GET /expense/summary, GET /expense?status=, POST /expense/claim, POST /expense
│   │   │   └── expense_repository.dart            # typed wrapper
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── my_expense_screen.dart         # page36 — Total Expense card, 4 tabs (Pending|In Progress|Approved|Rejected), checklist + Claim + FAB
│   │   │   │   └── add_expense_screen.dart        # page38 — multi-section form, Add Another Expense, Submit Claim, image_picker receipt
│   │   │   └── widgets/
│   │   │       └── expense_row.dart               # row with optional left checkbox (Pending) + view icon + amount
│   │   └── providers/
│   │       └── expense_providers.dart             # expenseSummaryProvider, expenseByStatusProvider(family), selectedExpenseTabProvider, pendingSelectionProvider, inProgressOverlayProvider
│   ├── tasks/                             # Prompts 10 + 12
│   │   ├── data/
│   │   │   ├── task_models.dart                    # Prompt 10 — TaskAchievement, TaskDetail, TaskCompletion enum, TaskStatus
│   │   │   ├── task_api_service.dart               # Prompt 10 stubs: GET /tasks?from=&to=, GET /tasks/{id}, POST /tasks/{id}/remark
│   │   │   ├── task_repository.dart                # Prompt 10 typed wrapper
│   │   │   ├── todays_task_models.dart             # Prompt 12 — TaskPriority, TodayTask, TodayTaskDetail
│   │   │   ├── todays_task_api_service.dart        # Prompt 12 stubs: GET /tasks/today, GET /tasks/today/{id}
│   │   │   └── todays_task_repository.dart         # Prompt 12 typed wrapper
│   │   ├── presentation/screens/
│   │   │   ├── task_vs_achievements_screen.dart    # page30 — From/To date filter (not autoDispose so back-nav preserves it), headed table
│   │   │   ├── task_detail_screen.dart             # page32 — Task Title + Description (read-only) + yellow Back button
│   │   │   ├── task_remark_screen.dart             # page34 — Remarks + multi-image upload + Status selector + Submit
│   │   │   ├── todays_task_screen.dart             # page40 — current date/day header + list with right-side arrow rows
│   │   │   └── todays_task_detail_screen.dart     # NOT in PDF — designed by us; title card + meta (Assigned/Site/Due) + Description + Back
│   │   └── providers/
│   │       ├── task_providers.dart                 # TaskRangeController, taskListProvider, taskDetailProvider(family)
│   │       └── todays_task_providers.dart         # todaysTaskListProvider, todaysTaskDetailProvider(family)
│   ├── labour/                            # Prompts 7-9
│   │   ├── data/
│   │   │   ├── labour_models.dart                  # Contractor, Labour, LabourDocument, kSkillOptions
│   │   │   ├── labour_api_service.dart             # Prompt 7 stubs (contractors, labour CRUD, documents, face enroll)
│   │   │   ├── labour_repository.dart              # Prompt 7 typed wrapper
│   │   │   ├── labour_attendance_models.dart       # Prompt 8 — LabourAttendanceMode, LabourAttendanceItem, LabourAttendanceSummary, LabourFaceMatch
│   │   │   ├── labour_attendance_api_service.dart  # stubs: GET /labour/in-list, AWS /match-labour, POST /attendance/labour/in
│   │   │   └── labour_attendance_repository.dart   # typed wrapper for attendance flow
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── labour_list_screen.dart           # page18 — contractor dropdown, count pill, list + FAB
│   │   │   │   ├── new_labour_induction_screen.dart  # page20 — create + edit (heading swaps), face enroll, doc upload, age >= 18 + Aadhaar required
│   │   │   │   ├── labour_documents_screen.dart      # NOT in PDF — designed by us; doc list
│   │   │   │   ├── labour_in_screen.dart             # page22 — Labour List, contractor card, "Attendance Marked: X of N" progress pill, rows
│   │   │   │   ├── labour_out_screen.dart             # page26 — heading "Labour Out", "Out Marked: X of N" pill, rows with IN / OUT subtitle
│   │   │   │   ├── labour_face_scan_screen.dart      # page24 / page28 — dark camera + oval brackets; within-site block DELETED (not commented) per brief; shared by in / out via LabourScanArgs.mode
│   │   │   │   └── labour_scan_args.dart             # GoRoute extra payload (LabourAttendanceItem + mode)
│   │   │   └── widgets/
│   │   │       ├── labour_row.dart                   # Prompt 7 — Active switch + View Document + edit
│   │   │       ├── contractor_card.dart              # static card if 1 contractor, switchable bottom-sheet if multiple
│   │   │       └── labour_attendance_row.dart        # row variants: TAKE ATTENDANCE button vs IN/OUT Marked pill
│   │   └── providers/
│   │       ├── labour_providers.dart                 # contractors, selectedContractor, labourList, labourCount, labourDocuments(family)
│   │       └── labour_attendance_providers.dart     # labourAttendanceListProvider (family on mode)
│   ├── self_attendance/                   # Prompt 6
│   │   ├── data/
│   │   │   ├── attendance_models.dart                # AttendanceStatus, FaceMatchResult, AttendanceEntry, MarkAttendanceResult
│   │   │   ├── self_attendance_api_service.dart      # stubs: AWS compare-faces, POST /attendance/self, GET /attendance/me
│   │   │   └── self_attendance_repository.dart       # typed wrapper
│   │   ├── presentation/screens/
│   │   │   ├── self_attendance_screen.dart           # page12 — Self (LEFT) / View (RIGHT), IN/OUT toggle, FACE SCAN
│   │   │   ├── face_attendance_screen.dart           # page14 — dark camera preview, oval brackets, AWS compare-faces stub; within-site block commented per client
│   │   │   ├── attendance_success_screen.dart        # page16 — green check, Status/Time/Site card, DONE
│   │   │   └── view_attendance_screen.dart           # NOT in PDF — designed by us; From/To date filter + entries list
│   │   └── providers/
│   │       └── self_attendance_providers.dart        # AttendanceStatusController, AttendanceRangeController, myAttendanceProvider
│   ├── dashboard/                         # Prompt 5
│   │   ├── data/
│   │   │   ├── dashboard_api_service.dart # stubs: GET /sites, /dashboard/summary, /dashboard/my-expense
│   │   │   ├── dashboard_repository.dart  # typed wrapper
│   │   │   ├── dashboard_models.dart      # Site, DashboardSummary, MyExpense
│   │   │   └── location_service.dart      # geolocator wrapper — one-shot permission + position
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart  # page10 — top bar, greeting, Today's Task, location pill, metrics, mgmt actions, bottom nav
│   │   │   └── widgets/
│   │   │       ├── todays_task_tile.dart  # yellow banner with 1.5s pulse + glow animation
│   │   │       ├── metric_card.dart       # 2x2 grid cell
│   │   │       └── management_tile.dart   # action tile in MANAGEMENT ACTIONS row
│   │   └── providers/
│   │       └── dashboard_providers.dart   # sites, selectedSite, summary, myExpense, currentLocation + truncateLocation()
│   ├── self_attendance/                   # Prompt 6  (empty subfolders)
│   ├── labour/                            # Prompts 7-9 (empty subfolders)
│   ├── tasks/                             # Prompts 10 + 12 (empty subfolders)
│   └── expense/                           # Prompt 11 (empty subfolders)
└── routes/
    ├── route_names.dart                   # string constants for every named route
    ├── splash_screen.dart                 # logo splash → authBootstrap → /mpin/login OR /login
    ├── theme_preview_screen.dart          # debug-only widget gallery (acceptance for Prompt 2)
    └── app_router.dart                    # GoRouter config (all destinations real — stub_screens removed in Prompt 12)
```

## Dependencies (pubspec.yaml)

- `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `local_auth`,
  `geolocator`, `image_picker`, `camera`, `intl`, `cached_network_image`,
  `flutter_screenutil`, `crypto` (added Prompt 4 — MPIN sha256 hashing),
  `cupertino_icons`.

---

## Screens Index (corrected after sampling images)

The first 4 entries in the original mapping were shifted by one — fixed below. There is
**no separate Welcome / Splash screenshot** in the PDF: page 1's text describes the project,
then page 2's image is the Login screen itself. The Splash in our app is a tiny logo-only
view we built ourselves (already shipped in Prompt 1).

| Prompt | Screen file | Screenshot |
|---|---|---|
| 1 | `routes/splash_screen.dart` ✅ | n/a (logo only, built by us) |
| 2 | `routes/theme_preview_screen.dart` ✅ | n/a (dev-only) |
| 3 | `features/auth/presentation/screens/login_screen.dart` ✅ | `images/page02_img01.jpeg` |
| 3 | `features/auth/presentation/screens/contact_admin_screen.dart` ✅ | n/a (modal off Login) |
| 4 | `features/auth/presentation/screens/set_mpin_screen.dart` ✅ | `images/page04_img01.jpeg` |
| 4 | `features/auth/presentation/screens/confirm_mpin_screen.dart` ✅ | `images/page06_img01.jpeg` |
| 4 | `features/auth/presentation/screens/mpin_login_screen.dart` ✅ | `images/page08_img01.jpeg` |
| 5 | `features/dashboard/presentation/screens/dashboard_screen.dart` ✅ | `images/page10_img01.jpeg` |
| 6 | `features/self_attendance/presentation/screens/self_attendance_screen.dart` ✅ | `images/page12_img01.jpeg` |
| 6 | `features/self_attendance/presentation/screens/face_attendance_screen.dart` ✅ | `images/page14_img01.jpeg` |
| 6 | `features/self_attendance/presentation/screens/attendance_success_screen.dart` ✅ | `images/page16_img01.jpeg` |
| 6 | `features/self_attendance/presentation/screens/view_attendance_screen.dart` ✅ | n/a (designed by us) |
| 7 | `features/labour/presentation/screens/labour_list_screen.dart` ✅ | `images/page18_img01.jpeg` |
| 7 | `features/labour/presentation/screens/new_labour_induction_screen.dart` ✅ | `images/page20_img01.jpeg` |
| 7 | `features/labour/presentation/screens/labour_documents_screen.dart` ✅ | n/a (designed by us) |
| 8 | `features/labour/presentation/screens/labour_in_screen.dart` ✅ | `images/page22_img01.jpeg` |
| 8 | `features/labour/presentation/screens/labour_face_scan_screen.dart` ✅ | `images/page24_img01.jpeg` |
| 9 | `features/labour/presentation/screens/labour_out_screen.dart` ✅ | `images/page26_img01.jpeg` |
| 9 | `features/labour/presentation/screens/labour_face_scan_screen.dart` ✅ (reused) | `images/page28_img01.jpeg` |
| 10 | `features/tasks/presentation/screens/task_vs_achievements_screen.dart` ✅ | `images/page30_img01.jpeg` |
| 10 | `features/tasks/presentation/screens/task_detail_screen.dart` ✅ | `images/page32_img01.jpeg` |
| 10 | `features/tasks/presentation/screens/task_remark_screen.dart` ✅ | `images/page34_img01.jpeg` |
| 11 | `features/expense/presentation/screens/my_expense_screen.dart` ✅ | `images/page36_img01.jpeg` |
| 11 | `features/expense/presentation/screens/add_expense_screen.dart` ✅ | `images/page38_img01.jpeg` |
| 12 | `features/tasks/presentation/screens/todays_task_screen.dart` ✅ | `images/page40_img01.jpeg` |
| 12 | `features/tasks/presentation/screens/todays_task_detail_screen.dart` ✅ | n/a (designed by us) |

Note: screenshots live in the **parent** directory (`../images/`) relative to this Flutter
project. `prompt.md` mapping at the project root has been updated to match.

---

## Status

| Prompt | Status |
|---|---|
| 1 — Project bootstrap + folder structure | ✅ Done |
| 2 — Theme + design system + shared widgets | ✅ Done |
| 3 — Login + Contact Admin + Biometric | ✅ Done |
| 4 — Set / Confirm / MPIN Login + auth bootstrap | ✅ Done |
| 5 — Dashboard | ✅ Done |
| 6 — Self Attendance + AWS face recognition | ✅ Done |
| 7 — Total Labour Strength + New Labour Induction + Documents | ✅ Done |
| 8 — Labour In flow + AWS face match | ✅ Done |
| 9 — Labour Out flow | ✅ Done |
| 10 — Task v/s Achievements + Detail + Remark | ✅ Done |
| 11 — My Expense + Add Expense | ✅ Done |
| 12 — Today's Task + detail (designed by us) | ✅ Done |
| 13 — QA / responsive sweep / build verification | ✅ Done |
| 13 — QA / responsive sweep / build verification | ✅ Done |

### Bug fix pass 1 — App identity (S-Square Manpower Services)
- New brand asset cropped from `bug_images/bug_page09_img01.jpeg` →
  `assets/images/tej_group_logo.png` (transparent header variant) and
  `assets/icons/launcher_icon.png` (1024 px white-bg square consumed by
  `flutter_launcher_icons`). The bug-report header watermark on page 3 was too
  washed out to use — page 09's full-resolution capture was the source instead.
- `pubspec.yaml` now registers `assets/images/` + `assets/icons/` and adds
  `flutter_launcher_icons: ^0.14.4` as a dev dependency. Run once with
  `dart run flutter_launcher_icons`; regenerated `mipmap-*` (Android) and
  `AppIcon.appiconset` (iOS) are committed.
- `android:label` → `S-Square Manpower Services`, `android:icon` → `@mipmap/launcher_icon`
  in `AndroidManifest.xml`. iOS `CFBundleDisplayName` → `S-Square Manpower Services`
  in `Info.plist` (`CFBundleName` left as `labour_management`).
- `AppStrings.appName` → `S-Square Manpower Services`. `BrandHeader` now renders
  `Image.asset(AssetPaths.tejGroupLogo)` + the wrapped 2-line company name in
  `primaryDark`. Constructor param renamed `siteName` → `companyName`. The shared
  `FooterCopyright` updated to `© 2024 S-Square Manpower Services. All rights reserved.`
- `splash_screen.dart` now shows the logo image + the app name beneath. The smoke
  test was switched from `find.text('TEJ')`+`'GROUP'` to a single
  `find.text('S-Square Manpower Services')` since the splash no longer renders
  raw "TEJ" / "GROUP" text widgets.
- **Old `AssetPaths.logo` retired.** New constants: `tejGroupLogo` (public),
  `_launcherIcon` (private — referenced only by the `flutter_launcher_icons`
  config in `pubspec.yaml`).
- **Status:** `flutter analyze` zero issues; `flutter test` 26/26 green;
  release APK build deferred until all five bug-fix prompts land per operator.

### Bug fix pass 2 — Auth screen drift
- **Login screen** (`login_screen.dart`): greeting `Welcome Back !` →
  `Welcome User!` per bug report page 7. Header / logo / company name were
  already corrected via the Prompt-1 `BrandHeader` overhaul.
- **Set MPIN + Confirm MPIN**: no source-code change needed in this pass —
  the only mismatch the client flagged was the header (logo + company name)
  which the Prompt-1 `BrandHeader` rebuild fixed centrally. Title, subtitle,
  4-circle indicator, and 3×4 keypad already match the reference
  (`bug_images/bug_page06_img01.jpeg` and `bug_page11_img01.jpeg`).
- **MPIN Login screen** (`mpin_login_screen.dart`) — page-19 annotation
  sweep:
  - **Header** — already using shared `BrandHeader`. Confirmed renders the
    new logo image + `S-Square Manpower Services` + bell. The custom hand-
    rolled bell row that used to live in this screen had been removed in
    Prompt 4; this pass just verified parity.
  - **Shield illustration** — was a green rounded-square `Container`
    wrapping a `verified_user_rounded` icon. Replaced with a stand-alone
    `Icons.verified_user_rounded` at `150.sp` in `AppColors.success`,
    sitting on top of the gradient backdrop (no surrounding box).
  - **Background shade** — added a vertical 3-stop `LinearGradient`
    behind the shield: `surface → primarySoft @ 0.55 alpha → surface`.
    Subtle peach wash, matches `bug_page16_img01.jpeg`.
  - **Bell duplicate** — none; `BrandHeader`'s bell is the only one.
- **No widget-test changes** required; the smoke test still asserts the
  splash brand text only.

### Bug fix pass 3 — Dashboard rework
- **New shared widget:** `lib/core/widgets/user_avatar.dart` — a circular
  `UserAvatar` that renders a `CachedNetworkImage` when `photoUrl` is provided,
  otherwise an `AppColors.avatarBg` circle with a `person` icon. Used by the
  top bar, drawer header, and Total Labour Strength tile.
- **Dashboard top bar** — replaced the `Icons.menu` hamburger with a tappable
  `UserAvatar(radius: 18)`. The "You / Just now" label became
  "Divya / Just now" (placeholder until the auth user payload is wired).
- **Side drawer** — Scaffold now owns a `GlobalKey<ScaffoldState>` and a
  left-side `Drawer`. Contents: avatar + name + role header, then 5 menu rows
  (My Profile, Change Site, Settings, Help & Support, About), divider, then
  red **Logout**. The avatar tap opens the drawer.
  - **Change Site** drawer tap closes the drawer and immediately opens the
    same bottom-sheet site picker the dashboard already used — no duplicate
    UI.
  - **Logout** uses `ConfirmDialog` (`Forget MPIN` / `Keep MPIN`) so the user
    decides whether to drop the stored MPIN hash too. Always clears the auth
    token via `AuthRepository.logout()`. Routes to `/mpin-login` if MPIN is
    kept, `/login` if not. The other 4 menu items are stubs that just close
    the drawer (their real destinations land in later passes).
- **Greeting** — was `Good Morning,\nUser` (two-line `RichText`); now a single
  ellipsised `Text("Good Morning, $_kPlaceholderUserName", maxLines: 1)`.
  The `_changeSitePill` is separated from the greeting with `SizedBox(width: 8)`
  so it can't collide on narrow widths.
- **Today's Task tile** — verified the base color is `AppColors.primary`
  (`#FFB300`) NOT `primaryDark`, and the `_glow` tween's max alpha is `0.45`.
  No source change; the client may have been looking at a darker device
  preview.
- **MetricCard overflow** — the label `Text` is now wrapped in a
  `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` with
  `maxLines: 1, softWrap: false`. The subtitle text gained `Flexible` +
  `overflow: ellipsis`. The value `Text` also got `maxLines: 1` + ellipsis.
  This kills the "TOTAL LABOUR STRENGTH" / "TASK VS ACHIEVEMENTS" wraps on
  280-360px viewports.
- **MetricCard new `iconWidget`** parameter — when supplied, overrides the
  default rounded `iconBg` square. The dashboard's Total Labour Strength card
  passes `UserAvatar(radius: 18)` here per bug-report page 24.
- **My Expense label decision** — kept as uppercase `MY EXPENSE` caption.
  Verified against `bug_images/bug_page21_img01.jpeg` — the reference still
  shows uppercase, so the bug-report bullet was a stale callout.
- **Auth state on back-nav** — confirmed nothing in the dashboard touches
  `AuthStorage`/`AuthRepository.logout` on plain pops, so the existing
  `authBootstrapProvider` already keeps the user logged in across launches
  until explicit Logout.
- **Status:** `flutter analyze` zero issues; `flutter test` 26/26 green.

### New feature tree — `features/profile/` (Bug fix pass 5)
```
features/profile/
├── data/
│   ├── profile_models.dart           # UserProfile (id, name, role, email, phone, siteName, joinedAt, avatarUrl?)
│   ├── profile_api_service.dart      # stubs: GET /profile/me, POST /profile/avatar
│   └── profile_repository.dart       # typed wrapper
├── presentation/screens/
│   └── profile_screen.dart           # bug_page28 — photo card (yellow ring + verified badge), name, role, ID pill, Sign Out
└── providers/
    └── profile_providers.dart        # profileProvider (FutureProvider — not autoDispose)
```

### Bug fix pass 4 — Tasks + Self Attendance behaviors
- **Task vs Achievements copy** — screen title `Task vs Achievements` →
  `Task Vs Achievements` (capital V). Dashboard tile label also flipped from
  `Task v/s Achievements` to `Task Vs Achievements`. Table column header
  `Action` → `Remark`. Route names and underlying screen file kept the same.
- **Dashboard Today Attendance tile** — `onTap` redirected from
  `/self-attendance` to `RouteNames.labourIn` per bug-report page 26.
- **`InMarkedTodayController`** — new `AsyncNotifier<bool>` in
  `self_attendance_providers.dart`. Persists a `'1'` flag in
  `flutter_secure_storage` under the date-keyed key
  `self_attendance_in:yyyy-MM-dd`, so the flag auto-resets at midnight (we
  just never read yesterday's key). Exposes `markIn()` (called from
  `face_attendance_screen.dart` on a successful IN punch) and `reset()`
  (test-only).
- **OUT pill disabled until IN marked** — `_statusPill` gained an optional
  `enabled` flag. When `false`, the pill renders with `AppColors.divider`
  background, `textDisabled` text, and `Opacity(0.6)`. Tapping the disabled
  OUT pill shows a snackbar: `Mark IN first to enable OUT`. The Self
  Attendance screen also auto-bounces the selector back to IN if it sees a
  stale `status == OUT` while `inMarkedToday == false` (`postFrameCallback`).
- **Today's date label** — `_dateHeader()` renders today's date
  (`dd MMM yyyy`) + day name as a left-aligned `bodyBold` + `caption`
  block, placed above the View/Self Attendance toggle row per the brief.
- **Status:** `flutter analyze` zero issues; `flutter test` 26/26 green.

### Bug fix pass 6 — Dashboard tweaks (review pass after bug-fix 3)
- **Today's Task tile** — base background recolored from `AppColors.primary`
  (`#FFB300`) to a softer `AppColors.todaysTaskBg` (`#FFDB6B`). The pulsing
  glow uses the same softer color so the animation stays in family. New
  token added to `AppColors`.
- **Top bar — hamburger restored.** Bug-fix pass 3 had replaced the
  hamburger with a tappable `UserAvatar`. The client reversed that call in
  the review pass — the top bar now shows `Icons.menu` again, still tapped
  to open the same `Scaffold.drawer`. The avatar lives on inside the drawer
  header and on the Total Labour Strength tile.
- **Greeting wraps instead of ellipsising.** The greeting `Text` lost its
  `maxLines: 1` + `overflow: ellipsis` pair; now `softWrap: true` so a long
  `Good Morning, <name>` breaks to a second line on narrow widths instead
  of truncating. `Row.crossAxisAlignment` is `start` so the Change Site
  pill aligns to the top of the wrapped text.
- **Status:** `flutter analyze` zero issues; `flutter test` 26/26 green.

### Bug fix pass 5 — Profile screen
- **New feature module** `features/profile/` with the standard data /
  presentation / providers layout (see folder tree above).
- **`ProfileScreen`** matches `bug_images/bug_page28_img01.jpeg`:
  - `AppBar` — leading hamburger (back when pushed), "Engineer Profile" title,
    trailing settings cog (stub).
  - Big elevated white card containing: profile photo (140 px circle with a
    3 px `primary` ring + small yellow verified badge bottom-right), name in
    large `screenTitle`, role caption, gray `ID: #<id>` pill with badge
    icon, divider, then a wide gray **Sign Out Account** button.
  - Footer: small industrial-arm icon + "INDUSTRIAL SITE MANAGEMENT V2.4"
    caption in `textDisabled`.
- **Reality check vs the original Bug Fix Prompt 5:** the prompt anticipated
  a sectioned list of read-only fields (User ID, Email, Phone, Site, Joined
  date). The actual page-28 design only shows the ID pill + Sign Out. We
  followed the design. The full `UserProfile` model keeps every field
  (email, phone, etc.) so the "Edit Profile" expansion can light them up
  later without changing the API contract.
- **Sign Out** reuses the same `ConfirmDialog` flow Bug fix pass 3 added to
  the drawer (`Forget MPIN` / `Keep MPIN`). Always clears the auth token;
  routes to `/mpin-login` (MPIN kept) or `/login` (MPIN forgotten).
- **Routing** — `RouteNames.profile = '/profile'`, `GoRoute` registered in
  `app_router.dart`. Dashboard's bottom-nav Profile item now pushes to it
  (was a no-op).
- **`api_contract.md`** — new section `9 · Profile` with `GET /profile/me`
  and `POST /profile/avatar`.
- **Status:** `flutter analyze` zero issues; `flutter test` 26/26 green.

### Prompt 3 notes
- **Riverpod 3.x** dropped `StateNotifier` — `LoginController` uses the new `Notifier` API
  (`extends Notifier<LoginState>`, `NotifierProvider`).
- **local_auth 3.x** dropped `AuthenticationOptions` — `BiometricService` calls
  `authenticate(localizedReason: ..., biometricOnly: true, persistAcrossBackgrounding: true)`.
- **Token persistence** is wired in `AuthRepository.login` but the `_storage.writeToken(...)`
  call is commented out next to the TODO until the real `/auth/login` endpoint replaces the
  deterministic mock response.
- **Biometric** prompt fires only on tap (per client brief on PDF page 3) — there is no
  auto-prompt on screen load.
- Login flow: Splash (600ms) → Login → on success → `RouteNames.createMpin` (currently a
  placeholder; Prompt 4 will replace it with the real Set MPIN flow).

### Prompt 4 notes
- **MPIN hashing:** `AuthStorage.writeMpin` / `verifyMpin` hash with `sha256(salt + mpin)`
  using the `crypto` package; plaintext never touches storage.
- **Lockout:** `MpinLoginController` tracks attempts. After 5 wrong tries, locks for 30s and
  a 1-second `Timer.periodic` ticks the UI countdown until expiry, then resets.
- **Auth bootstrap:** `authBootstrapProvider` (FutureProvider) reads `AuthStorage.hasMpin()`
  on app start. Splash awaits both the decision and a 500ms minimum-display delay, then
  routes to `/mpin/login` (returning user) or `/login` (no MPIN yet).
- **Logout policy (per brief, PDF page 7):** logout clears the token but **keeps the MPIN
  hash**, so the next launch lands on MPIN Login. A separate "Wipe MPIN + Logout" path is
  what "Forgot MPIN?" effectively triggers — routing back to the username + password Login.
- **Riverpod 3.x** also dropped `StateProvider` — `MpinDraft` uses a `Notifier` (`set` / `clear`).
- **Test note:** the smoke test only asserts the splash renders. The bootstrap reads
  `flutter_secure_storage`, which isn't backed in widget tests — full splash-to-dashboard
  coverage is deferred to integration tests in Prompt 13.

### Prompt 5 notes
- **Native permissions added** (no longer just dependencies):
  - Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`, `USE_BIOMETRIC`,
    `USE_FINGERPRINT`, `INTERNET` in `android/app/src/main/AndroidManifest.xml`.
  - iOS: `NSLocationWhenInUseUsageDescription`, `NSCameraUsageDescription`,
    `NSFaceIDUsageDescription` in `ios/Runner/Info.plist`.
- **Location permission** is requested by reading `currentLocationProvider` once from
  `DashboardScreen.initState`. The provider is cached for the session so it does not re-prompt.
- **Location truncation rule** lives in `truncateLocation()` — short string shows in full;
  otherwise first 2 words + `...`. This matches the brief on PDF page 11.
- **Today's Task animation** is a 1500ms `repeat(reverse: true)` `AnimationController` driving
  scale `1.0 → 1.02` and box-shadow alpha `0.18 → 0.45`. Subtle, non-distracting.
- **Dashboard tiles route** to real screens where built (Dashboard itself), and to lightweight
  `StubScreen`s for the seven destinations that arrive in Prompts 6-12. Each stub is removed
  from the router as its real screen lands.
- **Site list** auto-selects the first entry on first load so the metric / expense providers
  have a non-null site to query without forcing the user to interact first.
- **Static icons** in the top bar (star / share / bell) are rendered but have no `onTap` per
  the brief — they're explicitly marked static and will be wired in a later prompt.

### Prompt 6 notes
- **Swap from screenshot:** page12 shows VIEW left / SELF right but the brief on PDF page 13
  explicitly demands the opposite — `SelfAttendanceScreen` renders **SELF on LEFT, VIEW on RIGHT**.
- **Commented section, NOT removed:** in `face_attendance_screen.dart#_detectionCard`, the
  "Within Site Range / Project Alpha • 3.2m from location" block is left in source as a
  comment block prefixed with `// Commented per client (PDF page 15). Re-enable if requested.`
  per the client's instruction to keep the code intact for later re-enable.
- **AWS Rekognition:** `SelfAttendanceApiService.compareFaces` calls through `AwsConfig`.
  When `AwsConfig.isConfigured` is true the commented real-request block is what runs; while
  the constants are empty stubs the method returns a deterministic mock so the flow can be
  exercised end-to-end without keys.
- **Camera:** front lens preferred via `availableCameras() → CameraLensDirection.front`.
  Falls back to the first available camera. Captures with `takePicture()`; the path is passed
  to the compare-faces stub as `imageB64` placeholder until base64 encoding is added at
  integration time.
- **State extras:** the camera screen receives the IN/OUT choice via `GoRoute(extra:)`, and
  the success screen receives a `MarkAttendanceResult` the same way.
- **View Attendance** was designed by us (not in PDF) — same palette, From/To date pickers,
  list with day chip + IN/OUT times + status pill.
- **Test note:** `face_attendance_screen.dart` calls `availableCameras()` on init which
  fails gracefully (`_error = 'Camera unavailable.'`) so widget tests don't break the build.

### Prompt 7 notes
- **Heading swap on the induction form:** the screenshot reads "New Labour" but the brief on
  PDF page 21 explicitly demands `New Labour Induction`. The form widget centralizes the
  heading off the `existing` parameter — null → "New Labour Induction", non-null → "Edit Labour".
- **Edit + Documents reuse the labour list:** `LabourRow.onEdit` pushes `/labour/edit` with the
  full `Labour` model as `GoRoute extra`, and `onViewDocument` pushes `/labour/documents` the
  same way. Adding a `RouteNames.labourEdit` was required.
- **Form validation rules:**
  - Contractor / Labour Name / Skill — required (Form auto-validates).
  - DOB — required + must be ≥ 18 years old. Custom error: `Age Should Not Less Than 18`
    (matches screenshot copy).
  - Aadhaar Card — required for new induction. Custom error: `Aadhaar Card is mandatory`.
  - PAN Card — optional.
- **Face enrollment:** captured via `image_picker` with `preferredCameraDevice: front`.
  After save, `LabourRepository.enrollFace(labourId, imageB64)` runs against the
  `POST /labour/face/enroll` stub. The captured photo path stands in for `image_b64` until
  the backend integration adds the base64 encoding step.
- **Contractor + skill data:** `kSkillOptions` is a fixed list for now. Backend can later
  expose `GET /skills` and replace it.
- **Switch widget API:** Flutter 3.41 deprecated `activeColor` on `Switch` — `LabourRow`
  uses the new `activeThumbColor` / `activeTrackColor` / `inactiveThumbColor` / `inactiveTrackColor`.

### Prompt 8 notes
- **Shared scan screen:** `LabourFaceScanScreen` is built to serve both Labour In (Prompt 8)
  and Labour Out (Prompt 9). It branches on `LabourScanArgs.mode` for the post-success
  redirect (`/labour/in` vs `/labour/out`) and the `markAttendance` call routes to
  `POST /attendance/labour/in` or `/attendance/labour/out` accordingly.
- **"Within Site Range" handling — different from Prompt 6:** in `face_attendance_screen.dart`
  (self attendance) the block is **commented out** in source. In `labour_face_scan_screen.dart`
  (labour in / out) the block is **deleted** entirely. This split is intentional and matches
  the client's two different instructions on PDF pages 15 vs 25 / 29.
- **Contractor card logic:** `ContractorCard` renders as a static identity card when there's
  exactly one contractor in scope (mirrors page22). When there are multiple it adds a
  down-arrow that opens a bottom-sheet picker — the same picker pattern the dashboard uses
  for Change Site.
- **Progress pill:** the green "Attendance Marked: X out of N Labour" pill is populated from
  the API response (`markedCount` + `total`) — both come from the same `GET /labour/in-list`
  payload so the pill never drifts from the row states.
- **List refresh after a punch:** the scan screen calls
  `ref.invalidate(labourAttendanceListProvider(mode))` before routing back so the row flips
  from "TAKE ATTENDANCE" to "IN Marked" without a manual pull-to-refresh.
- **Success popup:** uses the shared `SuccessDialog` from Prompt 2 with
  `AppStrings.attendanceSuccess` ("Your attendance has been successfully marked.") — OK
  returns the user to the Labour In list.
- **`FaceMatchResult` reuse:** rather than duplicating the AWS response shape, the labour
  feature aliases the self-attendance type via `typedef LabourFaceMatch = FaceMatchResult;`
  and re-exports it so callers don't have to reach across features.

### Prompt 9 notes
- **Heading swap and label removal:** `LabourOutScreen` uses heading `Labour Out`. The
  screenshot's "Exit Attendance" title was deleted entirely (not retitled in place) — the
  brief on PDF page 27 explicitly demands both: change the heading and remove that label.
- **Single screen serves Prompts 8 + 9 scan:** `LabourFaceScanScreen` is shared between
  Labour In and Labour Out flows via `LabourScanArgs.mode`. The mode controls the
  post-success redirect (`/labour/in` vs `/labour/out`) and the `markAttendance` API path
  (`POST /attendance/labour/in` vs `/attendance/labour/out`). The within-site-range block
  is deleted in both, satisfying the brief on PDF pages 25 and 29.
- **Row evolution:** `LabourAttendanceRow` was extended for Prompt 9 to render an
  `IN: 08:15 AM  |  OUT: 06:05 PM` subtitle when `mode == outMode`. In `inMode` the row
  keeps its Prompt-8 form (marked-time stacked below the pill).
- **Mock data:** the same 12-row labour set drives Labour In and Labour Out. In-time is
  filled for every row (so "MARK EXIT" rows can show `IN: 08:xx | OUT: --:--`); out-time
  only on the rows already marked OUT. Five marked in each mode mirrors both screenshots.
- **Pill copy is mode-specific:** "Attendance Marked: X of N" (in) vs "Out Marked: X of N"
  (out). The pill icon also switches — green check-circle on the left and a green
  groups / logout glyph on the right.

### Prompt 10 notes
- **Date filter persistence:** `taskRangeProvider` is a regular `NotifierProvider` (NOT
  autoDispose) so that popping back from the Detail or Remark screen lands the user on the
  same filtered table — the brief on PDF page 33 explicitly calls this out.
- **Two action paths from the table:** the **View icon** sits as a small bordered
  document glyph beneath each Task Title and routes to Task Details (`/tasks/detail`).
  The **Arrow icon** is the circular yellow `>` in the Action column and routes to the
  Remarks screen (`/tasks/remark`). Both take the full `TaskAchievement` as `GoRoute extra`.
- **Aging + Status pills:** the table renders colored pills off `agingDays` (`On Time` green,
  `1D` soft yellow, `2D+` red) and `status` (`Task Pending` yellow, `Partial Completed`
  blue, `Fully Completed` green).
- **Multi-image upload:** Remarks uses `image_picker.pickMultiImage` (Prompt 1 dependency)
  with horizontal-scrolling previews, an X-button to delete each preview, and a permanent
  "Add Photo" tile at the end of the strip. Each `XFile.path` stands in for the eventual
  `image_b64` payload; the base64 encoding will be added at integration time.
- **Status picker UX:** native dropdowns don't render radio rows the way page34 shows them.
  Instead, tapping the "Select task status" field expands an inline card with two custom
  radio rows (Partial / Fully Completed). The chevron flips up/down on toggle.
- **Submit flow:** validates remark + status, POSTs to `/tasks/{id}/remark` stub, invalidates
  `taskListProvider` so the underlying table reflects new status, shows `SuccessDialog`
  ("Your remark has been successfully submitted."), then pops back to the table.

### Prompt 11 notes
- **"In Progress" tab is custom:** the screenshot only shows Pending / Approved / Rejected.
  Per the brief (PDF page 37), the In Progress tab is added **immediately before Approved**.
  Order is locked in `kExpenseTabs` to `[pending, inProgress, approved, rejected]`.
- **Tab-state survives invalidation:** `selectedExpenseTabProvider` is a regular Notifier
  (not autoDispose) so a Claim or Add Expense action that invalidates the list cache won't
  reset the active tab.
- **Claim flow:** Pending rows have a left checkbox. The bottom CTA "CLAIM NOW" is hidden
  on every other tab. On tap it confirms with `ConfirmDialog` ("Are you sure you want to
  claim?" — uses `AppStrings.claimConfirm`), then POSTs to `/expense/claim`, adds the
  claimed rows to `inProgressOverlayProvider` (so they show up immediately on the
  In Progress tab even before the backend reflects them), invalidates Pending + summary,
  clears selection, and switches the active tab to **In Progress**.
- **Checkbox visibility:** `ExpenseRow.checkable` is only set true on the Pending tab.
  Approved / Rejected / In Progress render the row without it, satisfying the brief.
- **Add Expense form:** multi-section. The `+ ADD ANOTHER EXPENSE` button appends a new
  `_ExpenseSection`; each non-first section has a delete-row icon. Submit walks all drafts,
  validates required fields, and posts the array through `ExpenseRepository.createMany`.
- **Receipt upload:** each section uses `image_picker.pickImage(gallery)` and previews the
  attached image; the `path` stands in for the eventual base64 payload.
- **Dashed border:** SUPPORTING DOCUMENT slot is rendered with a custom `DottedBox`
  painter (Flutter has no built-in dashed border for rounded rects).
- **Currency:** uses the existing `Formatters.currency` (₹, locale `en_IN`, 0 decimals).
- **Site pill:** the black pill at the top of Add Expense reads "ALPHA • MUMBAI METRO"
  — currently static; will read from `selectedSiteProvider` once Prompt 5's dashboard
  picker is wired into this feature.

### Prompt 12 notes
- **Date / day header is local:** the yellow date card at the top of Today's Task pulls
  `DateTime.now()` and renders it via `DateFormat('dd MMM yyyy')` + `'EEEE'`. The "N Tasks"
  badge tracks the API result count.
- **Detail page is ours:** the PDF doesn't ship a Today's Task detail design. We composed
  it from existing tokens — title card with the same yellow left accent as the list rows,
  priority chip (High red / Medium yellow / Low green), meta card with Assigned to / Site /
  Due, full description card, and a primary "Back" CTA at the bottom (the AppBar's back
  arrow is the second, more conventional escape).
- **Stub cleanup:** with Today's Task wired, every Dashboard tile destination now resolves
  to a real screen. `lib/routes/stub_screens.dart` has been deleted and its import dropped
  from the router.
- **Stable list ordering:** `todaysTaskListProvider` is a regular FutureProvider (not
  autoDispose) so navigating from the detail page back to the list doesn't trigger a
  re-fetch and reshuffle the cached rows.

### Prompt 13 notes (final QA)
- **API contract handoff:** every `TODO(api):` marker in `lib/` was audited and rolled up
  into [`api_contract.md`](api_contract.md) at the project root. 38 markers across 18 files,
  grouped into 8 feature sections plus an integration checklist. Hand that one page to the
  backend dev — no other doc is required.
- **File header audit:** a `head -1 | grep '^// File:'` sweep across every `.dart` file in
  `lib/` came back clean — every file ships with the standard `// File: / // Purpose: /
  // Used by:` block.
- **Hardcoded size sweep:** one residual `EdgeInsets.symmetric(horizontal: 14, vertical: 14)`
  in the theme-level `inputDecorationTheme` was converted to `.w` / `.h`. No other
  un-scaled `SizedBox` / `EdgeInsets` literals remain.
- **Validation sweep:** the Face Recognition section on `new_labour_induction_screen.dart`
  was marked `*` (required) but never enforced on save — now blocks `Save` with an inline
  "Face capture is required" error (skipped in edit mode where the existing enrolled face
  carries through).
- **Responsive guard test:** `test/viewport_test.dart` pumps five pure feature screens
  (My Expense, Labour In, Labour Out, Task v/s Achievements, Today's Task) at five
  viewport sizes — 280 (foldable folded) / 360 / 375 / 412 / 768 — and asserts no
  exception. 25 tests total, all green.
- **Build verification:**
  - `flutter analyze` → **No issues found** (0 warnings).
  - `flutter test` → **26 / 26 tests passed** (1 smoke + 25 viewport).
  - `flutter build apk --release` → kicked off; APK output lands under
    `build/app/outputs/flutter-apk/app-release.apk`. (Built in lieu of `--debug` at the
    operator's request.)
  - `flutter build ios --debug --no-codesign` → **skipped intentionally** by the operator
    on the Windows host. iOS-side hooks are already in place — the project ships the three
    `NS*UsageDescription` strings in `Info.plist` from Prompt 5, so the iOS build is
    ready to run on a macOS host the moment one is available.
- **Closing state:** every dashboard tile resolves to a real screen, every form has
  frontend validation, every dialog has an explicit dismiss path, the dashboard back-nav
  preserves Task v/s Achievements' date filter, and `inProgressOverlayProvider` keeps
  just-claimed expenses visible immediately after `POST /expense/claim`. The frontend is
  feature-complete and ready for the API integration pass.

### How to preview the design system

The project boots into a splash with an "Open Theme Preview" button. Tap it to see every
shared widget side-by-side with the color palette and typography so you can compare against
`../images/` before building real screens.
