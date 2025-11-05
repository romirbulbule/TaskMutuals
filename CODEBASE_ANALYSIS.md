# TaskMutuals Application - Comprehensive Codebase Analysis

**Last Updated:** November 5, 2025  
**Total Lines of Swift Code:** ~8,649  
**Total Swift Source Files:** 49  
**Total Git Commits:** 39  
**Repository:** https://github.com/romirbulbule/TaskMutuals.git

---

## EXECUTIVE SUMMARY

TaskMutuals is a **full-featured iOS marketplace platform** (SwiftUI + Firebase) connecting service seekers with service providers. The app enables users to post tasks, respond with quotes, chat with matches, and manage profiles. The codebase follows a clean MVVM architecture with real-time Firestore synchronization.

**Current Status:** Phase 1 of marketplace features is largely complete with production-ready authentication, user profiles, task posting, task responses, and messaging.

---

## 1. TECHNOLOGY STACK

### Frontend
- **Framework:** SwiftUI (iOS)
- **Architecture Pattern:** MVVM (Model-View-ViewModel)
- **Minimum iOS Version:** iOS 15+ (implied from SwiftUI usage)
- **Development Tool:** Xcode (xcodeproj configuration)

### Backend & Services
- **Database:** Firebase Firestore (NoSQL, real-time)
- **Authentication:** Firebase Auth (email/password with email verification)
- **File Storage:** Firebase Storage (profile images at `profileimages/{uid}.jpg`)
- **Analytics:** Firebase Analytics

### Third-party Libraries (via Swift Package Manager)
- **FirebaseAnalytics** - Event tracking
- **FirebaseAuth** - User authentication
- **FirebaseFirestore** - Database operations
- **FirebaseStorage** - Cloud file storage
- **TOCropViewController** - Image cropping UI component
- **CropViewController** - Alternative image cropping component

### Build & Configuration
- **Package Manager:** Swift Package Manager (SPM)
- **Configuration:** Info.plist (permissions for photo library and background notifications)
- **Firebase Config:** GoogleService-Info.plist (not tracked in git)

---

## 2. PROJECT STRUCTURE

```
/Documents/TaskMutuals/
├── TaskMutual/                          # Main source code
│   ├── Root Views (entry point)
│   │   ├── TaskMutualApp.swift         # App entry, Firebase initialization
│   │   ├── ContentView.swift           # Root view wrapper
│   │   ├── RootSwitcherView.swift      # Navigation state router
│   │   ├── MainTabView.swift           # 4-tab main interface
│   │   ├── SplashScreen.swift          # 1.5s launch animation
│   │   └── Theme.swift                 # Color & branding constants
│   │
│   ├── Authentication (6 views)
│   │   ├── Login/
│   │   │   ├── LoginView.swift         # Login screen with email/password
│   │   │   ├── SignUpView.swift        # Registration screen
│   │   │   ├── ForgotPasswordView.swift # Password reset via email
│   │   │   ├── NameEntryView.swift     # First/last name setup
│   │   │   ├── UsernameEntryView.swift # Unique username selection
│   │   │   └── EmailVerificationWaitingView.swift # Email verification UI
│   │
│   ├── Task Management (core feature)
│   │   ├── Task.swift                  # Data model (task & response enums/structs)
│   │   ├── TasksViewModel.swift        # Task CRUD & filtering logic
│   │   ├── FeedView.swift              # Blank/deprecated feed view
│   │   ├── MainFeedView.swift          # Primary task feed display
│   │   ├── TaskCardView.swift          # Task card component
│   │   ├── TaskDetailView.swift        # Full task details + responses
│   │   ├── PostTaskView.swift          # Task creation form
│   │   ├── EditTaskView.swift          # Task editing (stub)
│   │   ├── ResponseView.swift          # Provider response display
│   │   ├── EditResponseView.swift      # Response editing
│   │   └── SearchView.swift            # Category browsing (11KB file)
│   │
│   ├── User Profile (10 views)
│   │   ├── Profile/
│   │   │   ├── UserProfile.swift       # Data model + UserType enum
│   │   │   ├── ProfileView.swift       # User profile display
│   │   │   ├── ProfileSetupView.swift  # Initial profile creation (onboarding)
│   │   │   ├── UserTypeSelectionView.swift # Service seeker vs provider selection
│   │   │   ├── EditProfileView.swift   # Profile editing
│   │   │   ├── ImagePicker.swift       # Photo library picker
│   │   │   ├── CropView.swift          # Image cropping interface
│   │   │   ├── CropperSheet.swift      # Cropper presentation logic
│   │   │   └── MultilineTextField.swift # Custom bio text input
│   │
│   ├── Messaging (6 views + ViewModels)
│   │   ├── Chat/
│   │   │   ├── Chat.swift              # Chat & Message models
│   │   │   ├── ChatViewModel.swift     # Chat list management
│   │   │   ├── MessagesViewModel.swift # Message CRUD & real-time sync
│   │   │   ├── ChatView.swift          # Chat list screen
│   │   │   ├── ConversationView.swift  # Active conversation UI
│   │   │   └── UserSearchView.swift    # User search for new chats
│   │
│   ├── Core ViewModels (state management)
│   │   ├── AuthViewModel.swift         # Auth state, login/signup/logout
│   │   ├── UserViewModel.swift         # Profile CRUD & user search
│   │   └── TasksViewModel.swift        # Task management & filtering
│   │
│   ├── Utilities
│   │   ├── UserService.swift           # User service helper (light wrapper)
│   │   ├── ModalManager.swift          # Modal presentation state
│   │   ├── CustomLoadingView.swift     # Loading indicator component
│   │   ├── Item.swift                  # Generic placeholder model
│   │   ├── TaskPost.swift              # Task post data wrapper
│   │   └── Info.plist                  # iOS permissions (photo library)
│   │
│   └── Assets.xcassets/               # Images, icons, colors, app icon
│
├── TaskMutualTests/                    # Unit tests (minimal)
├── TaskMutualUITests/                  # UI tests (minimal)
├── TaskMutual.xcodeproj/              # Xcode project config
│   └── project.pbxproj                # Build configuration
│
├── ClaudeXcodeExtension/              # Xcode IDE extension (supplementary)
├── CLAUDE.md                          # Developer guide (detailed!)
└── .git/                              # Git repository
```

### Directory Breakdown
- **Login/** - 6 authentication-related views (~13KB total)
- **Profile/** - 10 profile management views (~35KB total)  
- **Chat/** - 6 messaging views and ViewModels (~15KB total)
- **Root Level** - Task management, main views, ViewModels (~30KB total)

---

## 3. FEATURES IMPLEMENTED

### Authentication & Onboarding
✅ Email/password registration with Firebase Auth  
✅ Email verification requirement (enforced before app access)  
✅ Password reset via email link  
✅ Login with persistent session  
✅ Sign out functionality  
✅ Account deletion (entire user data cascade deleted)  
✅ Re-authentication for sensitive operations  

### User Management
✅ User profile creation with name, username, date of birth, bio  
✅ Profile image upload to Firebase Storage with JPEG compression (0.8 quality)  
✅ Image cropping interface (supports multiple crop libraries)  
✅ Username uniqueness validation (case-insensitive)  
✅ Bio editing (character limit enforcement in UI)  
✅ User type selection: "Looking for Services" or "Providing Services"  
✅ User search by username for chat initiation  
✅ Profile image caching from URLs  

### Task Management (Marketplace Core)
✅ Task creation with:
  - Title, description, category (15 service categories with icons)
  - Budget (optional), location, deadline, estimated duration
  - Proper creator tracking (userId + username)
  
✅ Task listing/feed with:
  - Real-time Firestore synchronization
  - Filtering by user type (seekers see own tasks; providers see seeker tasks)
  - Backward compatibility for legacy tasks without userType
  - Timestamp-based ordering (newest first)
  
✅ Task detail view with:
  - Full task metadata display (category, location, budget, deadline, duration)
  - Task status tracking (open, assigned, in_progress, completed, cancelled)
  - Visual status indicators with color coding
  
✅ Task editing (title, description updates)  
✅ Task deletion (creator only)  
✅ Task archiving  

### Task Responses (Provider Bidding)
✅ Providers can submit one response per task with:
  - Message/proposal text
  - Quoted price (optional, negotiable)
  - Automatic timestamp tracking
  
✅ Task creators can:
  - View all responses on a task
  - Edit response text (CRUD operations)
  - Accept responses to assign provider
  
✅ Response ownership validation (only creator can edit/delete own responses)  
✅ Duplicate response prevention (one response per provider per task)  

### Messaging & Chat
✅ Real-time chat between matched users  
✅ Chat list with last message preview  
✅ Conversation view with message bubbles  
✅ Message sending with persistence  
✅ User filtering by opposite user type (seekers can only chat with providers)  
✅ Timestamp display for messages  
✅ Message styling (different colors for sender/receiver)  

### Search & Discovery
✅ Browse by service category with scrollable grid (5 rows × 7 columns)  
✅ Category-based task filtering  
✅ User search by username  

### Navigation & UI
✅ Splash screen (1.5s animation)  
✅ State-based routing via RootSwitcherView  
✅ Tab navigation (Feed, Search, Chat, Profile)  
✅ Complex loading state management  
✅ Dark mode compatibility  
✅ Theme system with brand colors & accents  

---

## 4. DATABASE SCHEMA & MODELS

### Firestore Collections

#### **users/{uid}**
```swift
struct UserProfile {
    @DocumentID var id: String?           // Firebase UID
    var firstName: String                 // First name
    var lastName: String                  // Last name
    var username: String                  // Unique username
    var dateOfBirth: Date                 // Age verification
    var bio: String?                      // Profile bio (max 150 chars in UI)
    var profileImageURL: String?          // Cloud Storage URL
    var userType: UserType?               // .lookingForServices or .providingServices
}
```

#### **usernames/{lowercase_username}**
```swift
{
    uid: String                           // Reference to user doc
    username: String                      // Original-cased username
}
```
*Purpose: Fast username uniqueness validation with case-insensitive lookup*

#### **tasks/{taskId}**
```swift
struct Task {
    @DocumentID var id: String?
    var title: String
    var description: String
    var creatorUserId: String
    var creatorUsername: String
    var creatorUserType: String?          // "looking_for_services" or "providing_services"
    var timestamp: Date
    var responses: [Response]             // EMBEDDED ARRAY (not subcollection)
    var isArchived: Bool
    
    // Marketplace Phase 1
    var budget: Double?                   // USD
    var location: String?                 // Address/area
    var category: ServiceCategory?        // Service category enum
    var status: TaskStatus                // open, assigned, in_progress, completed, cancelled
    var deadline: Date?                   // Task deadline
    var estimatedDuration: String?        // e.g., "2-3 hours"
    var assignedProviderId: String?       // Accepted provider's ID
    var assignedProviderUsername: String? // Accepted provider's username
}

struct Response {
    var id: String                        // UUID
    var fromUserId: String                // Provider's ID
    var fromUsername: String              // Provider's username
    var message: String                   // Proposal/quote message
    var timestamp: Date
    var quotedPrice: Double?              // Quoted price (optional)
    var isAccepted: Bool                  // Accepted by task creator?
}
```

#### **chats/{chatId}**
```swift
struct Chat {
    @DocumentID var id: String?
    var participants: [String]            // Array of user UIDs [user1, user2]
    var lastMessage: String               // Preview of latest message
    var lastUpdated: Date                 // Chat recency timestamp
}

chats/{chatId}/messages/{messageId}
struct Message {
    @DocumentID var id: String?
    var senderId: String                  // User UID
    var text: String                      // Message content
    var timestamp: Date
}
```

### Data Model Relationships

```
User (AuthViewModel)
  ├── Profile (UserViewModel)
  │   ├── Created Tasks (TasksViewModel)
  │   │   ├── Responses (embedded in Task)
  │   │   └── Status tracking
  │   └── Chats (ChatViewModel)
  │       └── Messages (MessagesViewModel)
  │
Provider Response
  ├── Points to Task
  ├── Points to Provider (fromUserId)
  └── Can be accepted by task creator
```

### Key Data Patterns
- **Denormalization:** creatorUsername & creatorUserType are stored with tasks for UI efficiency
- **Embedded Arrays:** Task responses are embedded in task document (max 1MB limit)
- **Subcollections:** Only chat messages use subcollections (for scalability)
- **Snapshot Listeners:** Real-time sync on feeds, chats, and messages
- **Uniqueness:** Usernames validated via separate `usernames/` collection
- **Caching:** Username cached in UserDefaults after login

---

## 5. ARCHITECTURE & DESIGN PATTERNS

### MVVM Pattern
```
View Layer (SwiftUI)
    ↓
ViewModel Layer (@Published properties)
    ↓
Model Layer (Codable Firestore models)
    ↓
Service Layer (Firebase SDK)
```

### State Management
- **@Published** - ViewModel observable properties
- **@StateObject** - ViewModel ownership in views
- **@EnvironmentObject** - ViewModel propagation through hierarchy
- **@State** - Local view-only state
- **UserDefaults** - Persistent cache (username after login)

### ViewModel Responsibilities

**AuthViewModel** (Authentication)
- Firebase Auth state listener
- Sign up, sign in, sign out
- Email verification enforcement
- Password reset
- Account deletion (delegates to UserViewModel)
- Error handling with user-friendly messages

**UserViewModel** (User Profile)
- Profile CRUD (create, update, fetch)
- Username uniqueness checking
- Profile image upload & storage
- User search for chat
- Account deletion cascade (comprehensive cleanup)
- Bio editing with persistence

**TasksViewModel** (Task Management)
- Task feed fetching with real-time listeners
- Task filtering based on user type
- Task CRUD operations
- Response management (add, edit, accept)
- Prevents duplicate responses per user
- Handles backward compatibility for legacy tasks

**ChatViewModel** (Chat List)
- Fetch chats where current user is participant
- Order by recency
- Real-time updates via snapshot listener

**MessagesViewModel** (Conversation)
- Fetch messages for specific chat
- Send messages with persistence
- Update parent chat lastMessage/lastUpdated

### Navigation Flow
```
SplashScreen (1.5s delay)
    ↓
RootSwitcherView (decision logic)
    ├─→ NOT_LOGGED_IN
    │   ├─→ LoginView
    │   └─→ SignUpView → EmailVerificationWaitingView
    │
    ├─→ LOGGED_IN but NO_PROFILE
    │   └─→ ProfileSetupView
    │       └─→ UserTypeSelectionView (seeker or provider)
    │
    └─→ FULLY_AUTHENTICATED
        └─→ MainTabView (4 tabs)
            ├─→ Tab 1: MainFeedView (task feed)
            ├─→ Tab 2: SearchView (category browse)
            ├─→ Tab 3: ChatView (conversations)
            └─→ Tab 4: ProfileView (user profile)
```

### Real-time Data Synchronization
All list views use Firestore snapshot listeners:
```swift
db.collection("tasks")
    .order(by: "timestamp", descending: true)
    .addSnapshotListener { snapshot, error in
        // Auto-updates when data changes
    }
```
**Critical:** All listeners are removed in `deinit` to prevent memory leaks.

---

## 6. INCOMPLETE & MISSING FEATURES

### High Priority (MVP Needed)
- **Task Search/Filtering UI** - SearchView is mostly category browsing; needs search bar
- **Provider Rating System** - No ratings/reviews for quality assurance
- **Payment Integration** - No Stripe/PayPal integration; budget is metadata only
- **Task Completion Flow** - Marked as completed but no actual completion verification
- **Notifications** - Remote notifications configured in Info.plist but not implemented
- **Image Gallery for Tasks** - Tasks have no images, only text/metadata

### Medium Priority  
- **Profile Verification** - No ID verification or trust scores
- **Dispute Resolution** - No mechanism for handling disagreements
- **Task Editing UI** - EditTaskView is a stub (only 1 line of code)
- **Chat Media** - Messages are text-only; no image/file sharing
- **Read Receipts** - Noted in commits as planned but not implemented
- **Chat Background Customization** - Mentioned in commits as optional
- **Reporting System** - UI exists for reporting but no backend logic

### Lower Priority (Enhancement)
- **Push Notifications** - Background modes configured but not utilized
- **Advanced Search Filters** - Date range, budget range, location radius
- **Skill Endorsements** - Provider specialty/skill tagging
- **Testimonials** - User feedback system
- **Favorites/Bookmarks** - Save tasks for later
- **Analytics Dashboard** - Task completion rates, provider statistics
- **Dark Mode Icons** - May need refinement

### Known Issues/Technical Debt
- **Test Coverage:** Unit tests & UI tests directories exist but are largely empty
- **Error Handling:** Basic try-catch; could benefit from more specific error types
- **Image Caching:** Only username cached in UserDefaults; profile images fetched fresh
- **Backward Compatibility:** Code handles tasks without `creatorUserType` field
- **Hardcoded Values:** Some UI constants could be extracted to Theme
- **Comments:** Some old commit messages reference unfinished work

---

## 7. CONFIGURATION & DEPENDENCIES

### Firebase Setup
1. **GoogleService-Info.plist** required (not in git for security)
   - Download from Firebase Console
   - Place in TaskMutuals directory or TestMutualUITests
   
2. **Firebase Initialization**
   ```swift
   // TaskMutualApp.swift init()
   FirebaseApp.configure()
   ```

3. **Firestore Security Rules** - Assumes proper rules set in Firebase Console
   - User can read/write their own profile
   - Tasks readable by all, writable by creator
   - Chat messages readable by participants

### Swift Package Dependencies (SPM)
```
Firebase (via SPM)
├── FirebaseAnalytics (~> 11.0)
├── FirebaseAuth (~> 11.0)
├── FirebaseFirestore (~> 11.0)
└── FirebaseStorage (~> 11.0)

Image Processing
├── TOCropViewController (~> 2.6)
└── CropViewController (~> 2.5)
```

### Info.plist Permissions
```xml
NSPhotoLibraryUsageDescription: "We need access to your photo library so you can select a profile picture."
UIBackgroundModes: ["remote-notification"]
```

### UIAppearance Configuration (TaskMutualApp.swift)
```swift
UITabBar.appearance().barTintColor = BrandBackground
UITabBar.appearance().tintColor = White
UITabBar.appearance().unselectedItemTintColor = White (50% alpha)
```

---

## 8. DEVELOPMENT WORKFLOW

### Project Setup
```bash
# Clone repo
git clone https://github.com/romirbulbule/TaskMutuals.git
cd TaskMutuals

# Open in Xcode (not the TaskMutual folder, the .xcodeproj)
open TaskMutual.xcodeproj

# Dependencies auto-resolve on first build via SPM
# Add GoogleService-Info.plist to TaskMutuals directory
```

### Build & Run
```bash
# Build
xcodebuild -scheme TaskMutual -sdk iphonesimulator -configuration Debug build

# Run tests
xcodebuild test -scheme TaskMutual -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests only
xcodebuild test -scheme TaskMutual -only-testing:TaskMutualUITests
```

### Key Files to Modify When Adding Features

| Feature | Files |
|---------|-------|
| New Task Property | Task.swift, PostTaskView.swift, TaskDetailView.swift, TasksViewModel.swift |
| New User Property | UserProfile.swift, ProfileSetupView.swift, EditProfileView.swift, UserViewModel.swift |
| New Chat Feature | Chat.swift, ConversationView.swift, MessagesViewModel.swift |
| New Tab | MainTabView.swift, RootSwitcherView.swift (navigation logic) |
| New Collection | Firestore security rules, add Codable struct, add ViewModel |

### Testing
- **Unit Tests:** TaskMutualTests/ uses Swift Testing framework (@Test macro)
- **UI Tests:** TaskMutualUITests/ uses XCTest
- **Test Accounts:** Should use Firebase Auth emulator for isolation
- **Mocking:** Not currently implemented; Firebase live during tests

---

## 9. CODE STYLE & CONVENTIONS

### Naming
- **ViewModels:** `*ViewModel.swift` (e.g., TasksViewModel)
- **Views:** `*View.swift` (e.g., TaskDetailView)
- **Models:** Simple nouns (e.g., Task, UserProfile, Chat)
- **Enums:** `ServiceCategory`, `TaskStatus`, `UserType`
- **Descriptive Props:** `creatorUserId` not `uid`, `quotedPrice` not `price`

### File Organization
- One primary type per file
- Group related views in folders (Login/, Profile/, Chat/)
- Root-level views in main TaskMutual/ directory
- No loose files; everything has a clear home

### SwiftUI Conventions
- Use `VStack`, `HStack`, `ZStack` for layout
- `@EnvironmentObject` for ViewModels (passed from App)
- Consistent padding/spacing (usually 12-16pt)
- Custom colors via `Theme` constants
- Proper view hierarchy (no views deeper than 4-5 levels)

### Error Messages
- User-friendly error handling in ViewModels
- Console logging with emoji prefixes (📋, ❌, ✅, 🗑️)
- Result<T, Error> types for async operations
- Error types like `UserVMError` for custom errors

---

## 10. SUMMARY TABLE

| Category | Status | Details |
|----------|--------|---------|
| **Authentication** | ✅ Complete | Email/password, verification, password reset |
| **User Profiles** | ✅ Complete | Creation, editing, image upload, type selection |
| **Task Posting** | ✅ Complete | Full marketplace fields (category, budget, deadline, etc.) |
| **Task Feed** | ✅ Complete | Real-time, filtered by user type, proper pagination |
| **Task Responses** | ✅ Complete | Providers can quote, creators can accept |
| **Messaging** | ✅ Complete | Real-time chat with filtered participants |
| **Search** | ⚠️ Partial | Category browsing works; text search needs work |
| **Notifications** | ❌ Not Started | Configured but not implemented |
| **Payments** | ❌ Not Started | No integration; budget is metadata only |
| **Ratings/Reviews** | ❌ Not Started | No quality assurance mechanism |
| **Image Gallery** | ❌ Not Started | Tasks have no images beyond profile pic |
| **Disputes** | ❌ Not Started | No resolution mechanism |
| **Testing** | ⚠️ Minimal | Test files exist; coverage is sparse |

---

## 11. NEXT STEPS FOR DEVELOPMENT

### Immediate (Week 1-2)
1. Implement text search in SearchView (query task title/description)
2. Add image gallery support for task postings
3. Create task completion workflow (mark done, verify provider)
4. Write unit tests for ViewModels (Firebase mocking)

### Short Term (Week 3-4)
1. Integrate Stripe/PayPal for payment processing
2. Implement rating/review system post-completion
3. Add push notification support
4. Implement dispute resolution workflow

### Medium Term (Month 2)
1. Add location-based filtering (map view)
2. Implement provider certification system
3. Add advanced chat features (media, read receipts)
4. Create analytics dashboard for platform admins

### Long Term (Month 3+)
1. Multi-language support
2. Offline mode for task drafts
3. API for third-party integrations
4. Web portal for desktop users

---

## GIT COMMIT HISTORY SUMMARY

39 commits documenting progression from basic feed → full marketplace platform:

**Foundation (Commits 1-15)**
- Initial iOS setup with SwiftUI & Firebase
- Feed implementation with sample tasks
- Task CRUD operations (create, edit, delete)
- Real-time Firestore syncing
- Theme/branding system

**Authentication (Commits 16-20)**
- Login/signup with Firebase Auth
- Email verification enforcement
- Password reset functionality
- Account deletion with data cascade
- Session persistence

**Profile & Users (Commits 21-30)**
- User profile creation & editing
- Profile image upload with cropping
- Username uniqueness validation
- Bio editing with character limits
- User search for chat functionality

**Marketplace Features (Commits 31-35)**
- Task categorization (15 service types)
- Budget, location, deadline tracking
- Provider response/bidding system
- Price quoting capability
- User type selection (seeker vs. provider)
- Task filtering by user type

**Messaging (Commits 36-38)**
- Real-time chat functionality
- Message persistence
- Chat list with recency
- User filtering by opposite type

**Refinements (Commits 39)**
- UI/UX polish for dark mode
- Email link improvements
- Overall platform stabilization

---

## CONCLUSION

TaskMutuals has a **solid foundation** for a P2P marketplace platform. The authentication, user management, task management, and messaging systems are production-ready with Firebase integration. The main gaps are payment processing, quality assurance (ratings), notifications, and advanced features like disputes and task completion verification.

The codebase is well-organized, follows clean architecture principles, and is documented with CLAUDE.md guidance. With ~8,600 lines of Swift code across 49 files, it's a substantial iOS application at Phase 1 completeness.

**Recommendation:** Before production launch, prioritize:
1. Payment integration (Stripe/PayPal)
2. Rating system (post-task-completion)
3. Push notifications (engagement)
4. Dispute resolution (trust & safety)
5. Comprehensive testing (QA coverage)

