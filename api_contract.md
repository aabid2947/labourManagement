# api_contract.md

Single-page reference for the backend developer. Every `// TODO(api):` marker in
`lib/` is captured here with its HTTP method, path, request body, and response shape.

- **Base URL** — defined per-environment in [`lib/core/config/api_config.dart`](lib/core/config/api_config.dart) (`_devBaseUrl`, `_stagingBaseUrl`, `_prodBaseUrl`). All real base URLs are TODO; the dev base is currently `https://dev.api.placeholder.local`.
- **Auth header** — `Authorization: Bearer <token>` is attached by [`api_interceptor.dart`](lib/core/network/api_interceptor.dart). Token is read from `AuthStorage().readToken()` (the read call is wired but commented next to `TODO(api)` until the real `/auth/login` endpoint lands).
- **AWS Rekognition** — endpoint + keys live in [`lib/core/config/aws_config.dart`](lib/core/config/aws_config.dart). Empty stubs; `AwsConfig.isConfigured` gates the real-call path inside each Rekognition service.
- **Content-Type** — `application/json` unless an endpoint specifies multipart (face/document uploads).
- **Dates** — ISO-8601 over the wire. The UI formats to `DD-MM-YY` via `Formatters.date()`.

Every endpoint below has a deterministic mock response in the matching `*_api_service.dart`
file so the frontend flows are exercisable today. Each mock is sitting next to a commented
real-call block that just needs the URL/auth wired up.

---

## 1 · Auth

### `POST /auth/login`
[`features/auth/data/auth_api_service.dart`](lib/features/auth/data/auth_api_service.dart) · `login(...)`

| | |
|---|---|
| Request | `{username: string, password: string, siteId: string}` |
| Response | `{token: string, userId: string, role: 'site_engineer' \| 'safety_engineer', hasMpin: bool}` |
| Notes | On success `AuthRepository.login` calls `AuthStorage.writeToken(token)` — the call is currently commented next to the TODO. Uncomment when this endpoint is live. |

### `POST /contact-admin`
[`features/auth/data/auth_api_service.dart`](lib/features/auth/data/auth_api_service.dart) · `contactAdmin(...)`

| | |
|---|---|
| Request | `{name: string, email: string}` |
| Response | `{success: bool}` |

---

## 2 · Dashboard

### `GET /sites`
[`features/dashboard/data/dashboard_api_service.dart`](lib/features/dashboard/data/dashboard_api_service.dart) · `fetchSites()` · Also referenced by `features/auth/presentation/screens/mpin_login_screen.dart:30`.

| | |
|---|---|
| Response | `[{id: string, name: string}]` |

### `GET /dashboard/summary?siteId=`
[`features/dashboard/data/dashboard_api_service.dart`](lib/features/dashboard/data/dashboard_api_service.dart) · `fetchSummary(siteId)`

| | |
|---|---|
| Query | `siteId: string` |
| Response | `{totalLabour: int, todayAttendance: {present: int, total: int}, taskVsAchievements: {achieved: int, target: int}}` |

### `GET /dashboard/my-expense?siteId=`
[`features/dashboard/data/dashboard_api_service.dart`](lib/features/dashboard/data/dashboard_api_service.dart) · `fetchMyExpense(siteId)`

| | |
|---|---|
| Query | `siteId: string` |
| Response | `{advance: number, currency: string, total: number}` |

### `GET /reverse-geocode` (future)
[`features/dashboard/data/location_service.dart`](lib/features/dashboard/data/location_service.dart) · line 31

The dashboard currently renders `lat, lng` as the location label. When the backend exposes reverse geocoding, replace the TODO with a real call and return a human-readable address (e.g. "Mumbai Metro").

---

## 3 · Self Attendance

### `POST {AWS_REKOGNITION_ENDPOINT}/compare-faces`
[`features/self_attendance/data/self_attendance_api_service.dart`](lib/features/self_attendance/data/self_attendance_api_service.dart) · `compareFaces(...)`

| | |
|---|---|
| Request | `{image_b64: string, userId: string}` |
| Response | `{match: bool, confidence: number, name?: string, code?: string}` |
| Notes | The real call is gated on `AwsConfig.isConfigured`. Fill the AWS endpoint + keys in `lib/core/config/aws_config.dart` before integration. The frontend passes the captured image path today; switch to `base64Encode(await File(path).readAsBytes())` at integration. |

### `POST /attendance/self`
[`features/self_attendance/data/self_attendance_api_service.dart`](lib/features/self_attendance/data/self_attendance_api_service.dart) · `markAttendance(...)`

| | |
|---|---|
| Request | `{status: 'in' \| 'out', siteId: string, faceConfidence: number, location: {lat: number, lng: number}?}` |
| Response | `{success: bool, markedAt: ISO-8601}` |
| Notes | Today `siteId` is hardcoded to `'alpha'` in `face_attendance_screen.dart:99` — `TODO(api)` there flags it to switch to `selectedSiteProvider` once wired into this feature. |

### `GET /attendance/me?from=&to=`
[`features/self_attendance/data/self_attendance_api_service.dart`](lib/features/self_attendance/data/self_attendance_api_service.dart) · `fetchMyAttendance(...)`

| | |
|---|---|
| Query | `from: ISO-8601`, `to: ISO-8601` |
| Response | `[{date: ISO-8601, inTime: string?, outTime: string?, status: 'Present' \| 'Absent' \| 'Half-day' \| ...}]` |

---

## 4 · Labour (Induction + CRUD)

All under [`features/labour/data/labour_api_service.dart`](lib/features/labour/data/labour_api_service.dart).

### `GET /contractors`
| | |
|---|---|
| Response | `[{id: string, name: string}]` |

### `GET /labour/count?contractorId=`
| | |
|---|---|
| Query | `contractorId: string` |
| Response | `{total: int}` |

### `GET /labour?contractorId=`
| | |
|---|---|
| Query | `contractorId: string` |
| Response | `[{id: string, name: string, skill: string, contractorId: string, contractorName: string, active: bool, dob: ISO-8601, faceEnrolledId?: string, panCardUrl?: string, aadhaarUrl?: string}]` |

### `GET /labour/{id}/documents`
| | |
|---|---|
| Response | `[{type: 'Aadhaar' \| 'PAN' \| ..., url: string, uploadedAt: ISO-8601}]` |
| Notes | `labour_documents_screen.dart:99` has a follow-up TODO to open the resolved URL once the backend returns signed/public URLs. |

### `POST /labour`
| | |
|---|---|
| Request | `{contractorId, name, skill, dob: ISO-8601, panCardLocalPath?, aadhaarLocalPath?}` — switch local paths to multipart file uploads at integration |
| Response | `{id: string}` |

### `PUT /labour/{id}`
| | |
|---|---|
| Request | `{contractorId, name, skill, dob: ISO-8601}` |
| Response | `{success: bool}` |

### `POST /labour/face/enroll`
| | |
|---|---|
| Request | `{image_b64: string, labourId: string}` — used by both labour induction and AWS face matching downstream |
| Response | `{success: bool, faceId: string}` |

### `PATCH /labour/{id}/active`
| | |
|---|---|
| Request | `{active: bool}` |
| Response | `{success: bool}` |

---

## 5 · Labour Attendance (In / Out)

All under [`features/labour/data/labour_attendance_api_service.dart`](lib/features/labour/data/labour_attendance_api_service.dart).

### `GET /labour/in-list?contractorId=` · `GET /labour/out-list?contractorId=`
| | |
|---|---|
| Query | `contractorId: string` |
| Response | `{items: [{id, name, skill, marked: bool, markedTime?: string, inTime?: string, outTime?: string}], total: int, marked: int}` |

### `POST {AWS_REKOGNITION_ENDPOINT}/match-labour`
| | |
|---|---|
| Request | `{image_b64: string, labourId: string}` |
| Response | `{match: bool, confidence: number, name?: string, code?: string}` |
| Notes | Same `AwsConfig.isConfigured` gate as the self-attendance compare-faces. |

### `POST /attendance/labour/in` · `POST /attendance/labour/out`
| | |
|---|---|
| Request | `{labourId: string, timestamp: ISO-8601, location: {lat, lng}?}` |
| Response | `{success: bool, markedAt: ISO-8601}` |

---

## 6 · Tasks v/s Achievements

All under [`features/tasks/data/task_api_service.dart`](lib/features/tasks/data/task_api_service.dart).

### `GET /tasks?from=&to=`
| | |
|---|---|
| Query | `from: ISO-8601`, `to: ISO-8601` |
| Response | `[{id: string, title: string, assignedDate: ISO-8601, dueDate: ISO-8601, agingDays: int, status: 'Task Pending' \| 'Partial Completed' \| 'Fully Completed'}]` |

### `GET /tasks/{id}`
| | |
|---|---|
| Response | `{id: string, title: string, description: string}` |

### `POST /tasks/{id}/remark`
| | |
|---|---|
| Request | `{remark: string, completion: 'partial' \| 'full', images: [base64...]}` — frontend currently sends each `XFile.path`; switch to base64-encoded bytes at integration |
| Response | `{success: bool}` |

---

## 7 · Today's Task

All under [`features/tasks/data/todays_task_api_service.dart`](lib/features/tasks/data/todays_task_api_service.dart).

### `GET /tasks/today`
| | |
|---|---|
| Response | `[{id: string, title: string, summary: string, priority: 'low' \| 'medium' \| 'high'}]` |

### `GET /tasks/today/{id}`
| | |
|---|---|
| Response | `{id, title, description, priority, assignedTo: string, site: string, dueAt: ISO-8601}` |

---

## 8 · Expense (My Expense + Add Expense)

All under [`features/expense/data/expense_api_service.dart`](lib/features/expense/data/expense_api_service.dart).

### `GET /expense/summary`
| | |
|---|---|
| Response | `{total: number, pendingCount: int}` |

### `GET /expense?status=`
| | |
|---|---|
| Query | `status: 'pending' \| 'in_progress' \| 'approved' \| 'rejected'` |
| Response | `[{id: string, category: string, amount: number, date: ISO-8601, status: same enum, notes?: string, attachmentUrl?: string}]` |

### `POST /expense/claim`
| | |
|---|---|
| Request | `{ids: [string...]}` |
| Response | `{success: bool}` |
| Notes | After a successful claim the frontend overlays the moved rows on the In Progress tab via `inProgressOverlayProvider` — when the backend list reflects the new state, the overlay can be retired. |

### `POST /expense` (multi-item)
| | |
|---|---|
| Request | `{items: [{category, amount, date: ISO-8601, notes, attachmentLocalPath?}]}` — switch attachments to multipart at integration |
| Response | `{success: bool, ids?: [string...]}` |

### `GET /expense/{id}` (future)
[`features/expense/presentation/screens/my_expense_screen.dart`](lib/features/expense/presentation/screens/my_expense_screen.dart) · line 261

`ExpenseRow`'s eye icon is currently a no-op. When the backend exposes a per-expense detail endpoint, wire it up here.

---

## 9 · Profile

All under [`features/profile/data/profile_api_service.dart`](lib/features/profile/data/profile_api_service.dart). Added in Bug fix pass 5.

### `GET /profile/me`
| | |
|---|---|
| Response | `{id: string, name: string, role: string, email: string, phone: string, siteName: string, joinedAt: ISO-8601, avatarUrl?: string}` |
| Notes | The screen surfaces `id` as `ID: #<id>` (e.g. `ID: #SE-4421`). The full email / phone / joined date are part of the model but not yet rendered — held for a future "Edit profile" expansion. |

### `POST /profile/avatar`
| | |
|---|---|
| Request | `{image_b64: string}` — frontend currently sends a stub; switch to base64-encoded bytes (or multipart) at integration. |
| Response | `{avatarUrl: string}` |

---

## Integration checklist (for the backend dev)

1. Fill the three base URLs in `lib/core/config/api_config.dart` (dev / staging / prod).
2. Fill `lib/core/config/aws_config.dart` — `rekognitionEndpoint`, `accessKeyId`, `secretAccessKey`, `region`.
3. In `lib/core/network/api_interceptor.dart`, uncomment the `AuthStorage().readToken()` block on the `onRequest` interceptor.
4. For every endpoint above, replace the deterministic mock body inside the matching `*_api_service.dart` method with the real `_dio.<method>(...)` call — every method already has the real call commented out next to the mock to make this a copy-and-uncomment job.
5. In `AuthRepository.login`, uncomment `await _storage.writeToken(result.token);` once `/auth/login` returns a real token.
6. Decide on the attachment upload contract (base64 vs multipart) and update three call sites:
   - Self attendance face capture (`compareFaces`)
   - Labour face enrollment + match
   - Task remark images + expense receipts
7. Wire the real `siteId` into `face_attendance_screen.dart` (`selectedSiteProvider`) once the dashboard's site picker is shared across features.
