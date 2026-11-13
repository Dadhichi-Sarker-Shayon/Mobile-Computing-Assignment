# SwiftTodo 📝

A clean, minimal iOS to-do app built with **SwiftUI** and **Firebase** — created for the Mobile Computing course assignment.

## Features

- **Email & Password Authentication** — sign up, sign in, and sign out powered by Firebase Auth
- **Real-time Sync** — tasks stream live from Cloud Firestore via snapshot listeners
- **CRUD for Tasks** — create, edit, complete/uncomplete, and delete (swipe-to-delete)
- **Active / Completed Segments** — segmented control to filter tasks
- **User-scoped Data** — Firestore security rules ensure every user only ever sees their own tasks
- **Friendly Error Handling** — Firebase errors mapped to human-readable messages
- **Modern SwiftUI** — MVVM architecture, `@MainActor` view models, `ContentUnavailableView`, sheets with detents, subtle animations

## Screens

| Auth | Task List | Editor |
|:---:|:---:|:---:|
| Sign in / Sign up screen | Segmented task list with real-time updates | Create & edit sheet |

## Architecture

```
SwiftTodo/
├── SwiftTodoApp.swift        # App entry — configures Firebase
├── ContentView.swift         # Root router: auth state → login or task list
├── Models/
│   └── TodoTask.swift        # Task model + Firestore mapping
├── ViewModels/
│   ├── AuthViewModel.swift   # Firebase Auth state & flows
│   └── TaskViewModel.swift   # Firestore CRUD + real-time listener
├── Views/
│   ├── AuthView.swift        # Sign in / sign up
│   ├── TaskListView.swift    # Task list, segments, swipe actions
│   └── TaskEditorView.swift  # Create / edit sheet
```

**Pattern:** MVVM

```
View (SwiftUI) ──observes──▶ ViewModel (@MainActor) ──▶ Firebase (Auth + Firestore)
```

## Tech Stack

| Component | Technology |
|---|---|
| UI | SwiftUI (iOS 17+) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore (real-time) |
| Security | Firestore Security Rules |

## Getting Started

### Prerequisites
- macOS with Xcode 15+
- A [Firebase](https://console.firebase.google.com) project with **Authentication** (Email/Password) and **Cloud Firestore** enabled

### Setup
1. Clone the repo:
   ```bash
   git clone https://github.com/Dadhichi-Sarker-Shayon/Mobile-Computing-Assignment.git
   ```
2. In the Firebase console, add an iOS app and download `GoogleService-Info.plist`
3. Place it inside the `SwiftTodo/SwiftTodo/` folder (it is git-ignored for security)
4. Open `SwiftTodo.xcodeproj` in Xcode and press **⌘R**

### Firestore Security Rules
Deployed via `firebase.json`:
```bash
firebase deploy --only firestore:rules
```

## Data Model

**Collection:** `tasks`

| Field | Type | Description |
|---|---|---|
| `userId` | String | Owner's Firebase UID |
| `title` | String | Task title (required) |
| `description` | String | Optional details |
| `isCompleted` | Bool | Completion state |
| `createdAt` | Timestamp | Creation time |
| `updatedAt` | Timestamp | Last modified |

## Security

Firestore rules restrict every operation to the signed-in owner:

```javascript
match /tasks/{taskId} {
  allow create: if request.auth != null
                && request.resource.data.userId == request.auth.uid;
  allow read, delete: if request.auth != null
                      && resource.data.userId == request.auth.uid;
  allow update: if request.auth != null
                && resource.data.userId == request.auth.uid
                && request.resource.data.userId == request.auth.uid;
}
```

---

*Built by [Dadhichi-Sarker-Shayon](https://github.com/Dadhichi-Sarker-Shayon) — Mobile Computing Assignment*
