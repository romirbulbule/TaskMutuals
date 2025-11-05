# TaskMutuals - Quick Reference Guide

## At a Glance

**Project:** TaskMutuals iOS Marketplace Platform  
**Size:** ~8,650 lines of Swift | 49 source files | 39 commits  
**Architecture:** MVVM + Firebase Firestore  
**Status:** Phase 1 Complete - Core marketplace features working  

---

## Key Statistics

| Metric | Value |
|--------|-------|
| Source Files | 49 Swift files |
| Total Lines of Code | ~8,649 |
| Git Commits | 39 |
| View Components | 35+ |
| ViewModels | 5 (Auth, User, Tasks, Chat, Messages) |
| Data Models | 8 (User, Task, Response, Chat, Message, etc.) |
| Firebase Collections | 4 (users, usernames, tasks, chats) |
| Service Categories | 15 |
| Supported Task Status | 5 states |

---

## Architecture Overview

```
┌─────────────────────────────────────┐
│   SwiftUI Views (35+ components)    │
├─────────────────────────────────────┤
│   ViewModels (Auth/User/Tasks/Chat) │
├─────────────────────────────────────┤
│   Models (Codable Firestore types)  │
├─────────────────────────────────────┤
│   Firebase SDK (Firestore/Auth/Stor)│
└─────────────────────────────────────┘
```

---

## Feature Completion Matrix

### Tier 1: PRODUCTION READY
- Authentication (email/password, verification, password reset)
- User profiles (creation, editing, image upload, cropping)
- Task posting with full marketplace metadata
- Task feed with real-time sync and type-based filtering
- Task responses (provider bidding with optional quotes)
- Real-time messaging between users

### Tier 2: PARTIALLY DONE
- Search (category browsing works; text search incomplete)
- Notifications (configured but not implemented)

### Tier 3: NOT STARTED
- Payment processing (Stripe/PayPal)
- Rating system (quality assurance)
- Image gallery for tasks
- Dispute resolution
- Read receipts in chat
- Provider verification

---

## Main Files by Purpose

### Entry Point
- `TaskMutualApp.swift` - App initialization, Firebase setup
- `RootSwitcherView.swift` - Navigation routing logic
- `MainTabView.swift` - 4-tab main UI

### Authentication (Login/)
- `LoginView.swift` - Sign in screen
- `SignUpView.swift` - Registration
- `ForgotPasswordView.swift` - Password reset
- `EmailVerificationWaitingView.swift` - Verify email prompt

### Tasks (Root + SearchView.swift)
- `Task.swift` - Models (Task, Response, ServiceCategory, TaskStatus)
- `TasksViewModel.swift` - Task CRUD, filtering, responses
- `PostTaskView.swift` - Create task form
- `TaskDetailView.swift` - View task + manage responses
- `MainFeedView.swift` - Task feed display

### Profiles (Profile/)
- `UserProfile.swift` - User model + UserType enum
- `ProfileSetupView.swift` - Initial onboarding
- `UserTypeSelectionView.swift` - Seeker or provider choice
- `EditProfileView.swift` - Update profile
- `ImagePicker.swift` / `CropView.swift` - Image handling

### Chat (Chat/)
- `Chat.swift` - Chat & Message models
- `ChatViewModel.swift` - Chat list management
- `MessagesViewModel.swift` - Message CRUD
- `ConversationView.swift` - Active chat UI

### ViewModels (Root)
- `AuthViewModel.swift` - Auth state + login/logout
- `UserViewModel.swift` - Profile management
- `TasksViewModel.swift` - Task operations

---

## Database Collections

### users/{uid}
Profile data - firstName, lastName, username, dateOfBirth, bio, profileImageURL, userType

### usernames/{lowercase_username}
Uniqueness index - Maps username → uid

### tasks/{taskId}
Task + embedded responses array - title, description, budget, location, category, deadline, responses[], etc.

### chats/{chatId}/messages/{msgId}
Conversations - Two participants, messages are subcollection

---

## Navigation Flow

```
Splash (1.5s)
    ↓
[Logged in?] ──NO──→ Login/SignUp → Email Verify
    ↓YES
[Profile exists?] ──NO──→ Profile Setup → User Type Selection
    ↓YES
MainTabView
├── Feed (task list for your type)
├── Search (browse by category)
├── Chat (conversations)
└── Profile (your account)
```

---

## Completed User Flows

### Service Seeker Flow
1. Sign up → Email verification → Create profile
2. Select "Looking for Services"
3. Post task (title, desc, budget, category, location, deadline)
4. View responses from providers
5. Accept provider → Task status = "assigned"
6. Chat with accepted provider
7. Mark task complete

### Service Provider Flow
1. Sign up → Email verification → Create profile
2. Select "Providing Services"
3. Browse available tasks
4. Submit response with message + optional quote
5. Wait for task creator to accept
6. Once accepted, chat with customer
7. Complete task → Mark complete

---

## Most Important Code Patterns

### Real-time Listeners (Critical!)
```swift
db.collection("tasks")
    .addSnapshotListener { snapshot, error in
        // Auto-updates on changes
    }
// MUST remove in deinit to prevent leaks!
```

### Firestore CRUD
```swift
// Create
try db.collection("tasks").addDocument(from: task)

// Read
db.collection("tasks").document(id).getDocument { snapshot, error in
    let task = try? snapshot?.data(as: Task.self)
}

// Update
db.collection("tasks").document(id).updateData([...])

// Delete
db.collection("tasks").document(id).delete()
```

### Environment Objects
```swift
@EnvironmentObject var authVM: AuthViewModel
@EnvironmentObject var userVM: UserViewModel
@EnvironmentObject var tasksVM: TasksViewModel
```

---

## Quick Debugging Tips

### Enable Console Logging
ViewModels use emoji-prefixed logs:
- 📋 TasksViewModel operations
- ❌ Errors
- ✅ Success
- 🗑️ Deletion operations

### Check Auth State
```swift
if let user = Auth.auth().currentUser {
    let uid = user.uid
    let verified = user.isEmailVerified
}
```

### Inspect User Type Filtering
In TasksViewModel.fetchTasks():
- Seekers see their own created tasks
- Providers see seeker-created tasks
- Backward compatible with tasks without creatorUserType

---

## Required Setup

1. Firebase Project with:
   - Firebase Auth enabled
   - Firestore database
   - Storage bucket
   - GoogleService-Info.plist downloaded

2. Firestore Security Rules:
   - Users can read/write own profile
   - Tasks readable by all, writable by creator only
   - Messages readable by participants

3. Dependencies (via SPM):
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - TOCropViewController or CropViewController

---

## High Priority Missing Features

1. **Payment Processing** - Budget is metadata only
2. **Provider Ratings** - No quality assurance mechanism
3. **Task Search** - No text search; only category browse
4. **Push Notifications** - Configured but not implemented
5. **Task Completion Verification** - No actual completion flow

---

## Future Implementation Areas

### Month 1
- Add text search to SearchView
- Integrate Stripe/PayPal
- Implement rating system

### Month 2
- Push notifications
- Dispute resolution
- Map-based location search

### Month 3+
- Web portal
- Advanced analytics
- Multi-language support

---

## File Paths (for reference)

```
/Users/romirbulbule/Documents/TaskMutuals/
├── TaskMutual/                    # Main source
├── TaskMutualTests/               # Unit tests (sparse)
├── TaskMutualUITests/             # UI tests (sparse)
├── CLAUDE.md                      # Detailed dev guide
├── CODEBASE_ANALYSIS.md          # Full technical analysis
└── TaskMutual.xcodeproj/          # Xcode project
```

---

## Key Contacts (in code)
- Package Dependencies: Swift Package Manager
- Backend: Firebase Console (https://console.firebase.google.com)
- Repository: https://github.com/romirbulbule/TaskMutuals

