# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TaskMutuals is an iOS social task-sharing application built with SwiftUI and Firebase. Users can post tasks, respond to others' tasks, chat with other users, and manage their profiles. The app follows the MVVM architectural pattern with real-time data synchronization via Firestore.

## Build & Development Commands

### Building the Project
```bash
# Build for iPhone simulator
xcodebuild -scheme TaskMutual -sdk iphonesimulator -configuration Debug build

# Build for release
xcodebuild -scheme TaskMutual -configuration Release build

# Clean build artifacts
xcodebuild clean -scheme TaskMutual
```

### Running Tests
```bash
# Run unit tests
xcodebuild test -scheme TaskMutual -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -scheme TaskMutual -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TaskMutualUITests

# Run specific unit test
xcodebuild test -scheme TaskMutual -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TaskMutualTests/TaskMutualTests/testExample
```

### Development Workflow
- Open `TaskMutual.xcodeproj` in Xcode (not TaskMutuals directory)
- Swift Package Manager dependencies auto-resolve on first build
- Requires `GoogleService-Info.plist` for Firebase configuration (not tracked in git)
- Test in Xcode using Cmd+R (run) or Cmd+U (test)

## Architecture & Code Organization

### MVVM Pattern
The app uses SwiftUI's MVVM architecture with three key ViewModels:

1. **AuthViewModel** (`AuthViewModel.swift`) - Manages authentication state
   - Firebase Auth integration (email/password)
   - Email verification enforcement
   - Account deletion with re-authentication
   - Auth state listener in `init()`, cleanup in `deinit`

2. **UserViewModel** (`UserViewModel.swift`) - Handles user profile operations
   - Profile CRUD operations
   - Username uniqueness validation via `usernames` collection
   - Profile image upload to Firebase Storage
   - User search for chat functionality
   - Caches username in UserDefaults for quick access

3. **TasksViewModel** (`TasksViewModel.swift`) - Manages task feed and operations
   - Real-time task updates via Firestore snapshot listeners
   - Task CRUD operations (create, edit, delete, archive)
   - Response/comment management on tasks
   - Always cleanup listeners in `deinit`

### Navigation Flow
The app uses a state-based navigation system controlled by `RootSwitcherView.swift`:

```
SplashScreen (1.5s)
  ↓
RootSwitcherView (decision point)
  ├─→ LoginView → SignUpView → EmailVerificationWaitingView
  ├─→ ProfileSetupView (if new user)
  └─→ MainTabView (4 tabs: Feed, Search, Chat, Profile)
```

**Important Navigation Logic:**
- User must verify email before accessing the app
- Profile setup required for new users before main app access
- `RootSwitcherView` coordinates state transitions with loading states
- Environment objects (`@EnvironmentObject`) pass ViewModels through view hierarchy

### Directory Structure
```
TaskMutual/
├── Root Views
│   ├── TaskMutualApp.swift          # App entry, Firebase init
│   ├── RootSwitcherView.swift       # Navigation state router
│   ├── MainTabView.swift            # Main 4-tab interface
│   └── ContentView.swift            # Root wrapper
│
├── Login/                           # 6 authentication views
│   └── LoginView, SignUpView, ForgotPasswordView, etc.
│
├── Profile/                         # 10 profile-related views
│   └── ProfileView, EditProfileView, ImagePicker, CropView, etc.
│
├── Chat/                            # 6 messaging views & ViewModels
│   └── ChatView, ConversationView, ChatViewModel, etc.
│
└── Task Feed & Management           # Root-level task views
    └── FeedView, TaskCardView, PostTaskView, etc.
```

### Firestore Data Model

**Collections:**
```
users/{uid}
  ├─ firstName: String
  ├─ lastName: String
  ├─ username: String
  ├─ dateOfBirth: Date
  ├─ bio: String
  └─ profileImageURL: String

usernames/{lowercase_username}  ← Ensures username uniqueness
  ├─ uid: String
  └─ username: String

tasks/{taskId}
  ├─ title: String
  ├─ description: String
  ├─ creatorUserId: String
  ├─ creatorUsername: String
  ├─ timestamp: Date
  ├─ isArchived: Boolean
  └─ responses: [Response]  ← Embedded array, not subcollection

chats/{chatId}
  ├─ participants: [String]  ← Array of UIDs
  ├─ lastMessage: String
  ├─ lastUpdated: Date
  └─ messages/{messageId}    ← Subcollection
      ├─ senderId: String
      ├─ text: String
      └─ timestamp: Date
```

**Key Patterns:**
- Use `@DocumentID` for Firestore-generated IDs
- All models conform to `Codable` for Firestore Encoder/Decoder
- Username stored in both `users/{uid}` and `usernames/{username}` collections
- Use batched writes when updating multiple documents (see `createOrUpdateProfile`)
- Snapshot listeners for real-time updates (always cleanup in `deinit`)

## Firebase Integration

### Required Setup
1. Add `GoogleService-Info.plist` to project (Firebase console download)
2. Firebase initialized in `TaskMutualApp.init()` with `FirebaseApp.configure()`
3. Auth state listener starts automatically in `AuthViewModel.init()`

### Firebase Modules Used
- **FirebaseAuth** - Email/password authentication, email verification
- **FirebaseFirestore** - Real-time NoSQL database
- **FirebaseStorage** - Profile image storage at `profileimages/{uid}.jpg`
- **FirebaseAnalytics** - Event tracking (minimal usage)

### Storage Patterns
- Profile images compressed at 0.8 JPEG quality
- Images uploaded via `UserViewModel.uploadProfileImage(_:completion:)`
- Download URLs stored in Firestore `profileImageURL` field
- No local caching beyond UserDefaults for username

## Common Development Patterns

### Adding New Features
1. Create feature folder in `TaskMutual/` if needed (e.g., `Notifications/`)
2. Create ViewModel if state management required
3. Create SwiftUI views
4. Pass existing ViewModels via `@EnvironmentObject` if needed
5. Update Firestore collections as needed

### Real-time Data Synchronization
Always use snapshot listeners for live updates:
```swift
db.collection("tasks").addSnapshotListener { snapshot, error in
    // Handle updates
}
```
**Critical:** Store listener handle and remove in `deinit`:
```swift
private var listener: ListenerRegistration?

deinit {
    listener?.remove()
}
```

### State Management
- Use `@Published` for observable properties in ViewModels
- Use `@StateObject` for ViewModel ownership in views
- Use `@EnvironmentObject` for ViewModels passed through hierarchy
- Use `@State` for local view-only state
- All state updates must happen on main thread: `DispatchQueue.main.async { }`

### Authentication Flow
1. Sign up requires email verification before app access
2. Check `authViewModel.isLoggedIn` (combines auth + email verification)
3. Account deletion requires password re-authentication for security
4. Always use `authViewModel.currentUser` not `Auth.auth().currentUser` directly

### Firestore Operations
- Use `Firestore.Encoder().encode(model)` for writing Codable models
- Use `snapshot.data(as: ModelType.self)` for reading Codable models
- Use batch writes when updating multiple documents atomically
- Username changes require updating both `users` and `usernames` collections
- Account deletion should batch delete user doc, username doc, and all user's tasks

## Testing

### Current State
- Test infrastructure exists but largely unpopulated
- Unit tests in `TaskMutualTests/TaskMutualTests.swift` use new Swift Testing framework (`@Test`)
- UI tests in `TaskMutualUITests/` use XCTest framework

### Testing Approach
- Use `@testable import TaskMutual` to access internal APIs
- Mock Firebase services for unit tests (not currently implemented)
- UI tests can use XCUIApplication for end-to-end testing
- Test accounts should use Firebase Auth emulator for isolation

## Code Style & Conventions

### Naming Conventions
- ViewModels end with `ViewModel` suffix
- Views end with `View` suffix
- Models are simple nouns (e.g., `Task`, `UserProfile`, `Chat`)
- Use descriptive names: `creatorUserId` not `uid`

### File Organization
- One primary type per file
- File name matches primary type name
- Group related views in folders (Login/, Profile/, Chat/)
- Keep root-level views in main directory

### Error Handling
- ViewModels expose `@Published` error properties for UI display
- Use `Result<T, Error>` for async operations with completion handlers
- Provide user-friendly error messages (see `AuthViewModel.userFriendlyError`)
- Log errors to console for debugging: `print("Error: \(error)")`

## Common Gotchas

1. **Email Verification Required:** Users can't access app until email verified - check `isEmailVerified` in auth flow
2. **Username Uniqueness:** Must check `usernames` collection before allowing username (case-insensitive)
3. **Snapshot Listener Cleanup:** Forgetting to remove listeners causes memory leaks and crashes
4. **Main Thread Updates:** All `@Published` property changes must happen on main thread
5. **Profile Loading State:** `RootSwitcherView` has complex loading logic - understand state transitions before modifying
6. **Batch Operations:** Username changes and account deletion require multiple Firestore operations - use batches
7. **UserDefaults Caching:** Username cached in UserDefaults - keep in sync with Firestore
8. **Task Responses:** Stored as embedded array in task document, not as subcollection (unlike chat messages)
