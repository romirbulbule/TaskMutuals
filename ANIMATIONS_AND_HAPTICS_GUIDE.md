# TaskMutuals Animations & Haptics Guide

Complete guide to the premium animations and haptic feedback system inspired by Opal.

---

## 🎬 Animation System

### Animation Presets

All animations are spring-based for natural, fluid motion:

#### **Smooth** (Most Common)
- **Response**: 0.4s
- **Damping**: 0.8
- **Use for**: General UI transitions, view changes, fades

#### **Bouncy** (Playful)
- **Response**: 0.5s
- **Damping**: 0.6
- **Use for**: Success states, badges appearing, celebration

#### **Snappy** (Fast)
- **Response**: 0.3s
- **Damping**: 0.85
- **Use for**: Button presses, quick interactions, tab switches

#### **Gentle** (Subtle)
- **Response**: 0.6s
- **Damping**: 0.9
- **Use for**: Background transitions, subtle UI changes

### How to Use Animations

```swift
// In your SwiftUI view
.animation(AnimationPresets.smooth, value: someState)

// Or with withAnimation
withAnimation(AnimationPresets.bouncy) {
    // State changes here
}
```

---

## 📳 Haptic Feedback System

### Impact Feedback

#### **Light**
- Subtle vibration
- **Use for**: Tab switches, selection changes, swipes

#### **Medium**
- Standard vibration
- **Use for**: Button presses, standard interactions

#### **Heavy**
- Strong vibration
- **Use for**: Important actions, deletions, completions

#### **Soft** (iOS 13+)
- Very gentle
- **Use for**: Toggles, minor changes

#### **Rigid** (iOS 13+)
- Firm vibration
- **Use for**: Confirmations, significant changes

### Notification Feedback

#### **Success**
- Completion vibration
- **Use for**: Task completed, payment successful, rating submitted

#### **Warning**
- Alert vibration
- **Use for**: Warnings, cautionary actions

#### **Error**
- Failure vibration
- **Use for**: Errors, failed actions, validation issues

### Custom Patterns

#### **Button Press**
```swift
HapticsManager.shared.buttonPress()
```
Medium impact for standard button taps

#### **Task Completed**
```swift
HapticsManager.shared.taskCompleted()
```
Medium impact + success notification

#### **Payment Success**
```swift
HapticsManager.shared.paymentSuccess()
```
Heavy + success + light sequence (celebration!)

#### **Destructive Action**
```swift
HapticsManager.shared.destructive()
```
Heavy + error sequence

---

## 🎨 Animation Components

### 1. **AnimatedPrimaryButton**

Premium button with press animation and haptics:

```swift
AnimatedPrimaryButton("Post Task", icon: "plus.circle.fill") {
    // Action
}
```

**Features:**
- Scale effect on press (0.97x)
- Haptic feedback
- Loading state support
- Disabled state styling

---

### 2. **AnimatedSecondaryButton**

Outline button with subtle animation:

```swift
AnimatedSecondaryButton("Cancel", icon: "xmark") {
    // Action
}
```

**Features:**
- Light haptic feedback
- Border animation
- Clean, minimal design

---

### 3. **AnimatedCard**

Interactive card with smooth press animation:

```swift
AnimatedCard {
    // Your content here
    Text("Task Title")
}
```

**Features:**
- Subtle scale on press
- Shadow and rounded corners
- Tap gesture with haptics

---

### 4. **AnimatedToggle**

Toggle switch with smooth animation:

```swift
AnimatedToggle(isOn: $enableNotifications, label: "Notifications")
```

**Features:**
- Smooth spring animation
- Toggle haptic feedback
- Theme-matched colors

---

### 5. **AnimatedStarRating**

Interactive star rating with bounce:

```swift
AnimatedStarRating(rating: $rating, interactive: true)
```

**Features:**
- Stars bounce when tapped
- Light haptic for each star
- Yellow/gray colors

---

### 6. **AnimatedSuccessOverlay**

Full-screen success animation:

```swift
AnimatedSuccessOverlay(
    title: "Success!",
    message: "Task posted successfully"
) {
    // Dismiss action
}
```

**Features:**
- Animated checkmark
- Backdrop blur
- Bounce-in animation
- Success haptic

---

### 7. **AnimatedLoadingView**

Bouncing dots loader:

```swift
AnimatedLoadingView(message: "Loading tasks...")
```

**Features:**
- Three bouncing dots
- Staggered animation
- Optional message

---

### 8. **AnimatedEmptyState**

Beautiful empty states with animation:

```swift
AnimatedEmptyState(
    icon: "tray",
    title: "No tasks yet",
    message: "Post your first task to get started",
    actionTitle: "Post Task",
    action: { /* ... */ }
)
```

**Features:**
- Icon scales in
- Text fades in
- Optional CTA button
- Staggered animations

---

## 🎭 View Modifiers & Extensions

### Scale Animations

```swift
// Pressable scale effect
.pressableScale(isPressed: isPressing)

// Bounce scale
.bounceScale(trigger: shouldBounce)

// Spring pop (for appearing views)
.springPop(trigger: hasAppeared)
```

### Fade Animations

```swift
// Smooth fade in
.smoothFadeIn(delay: 0.2)

// Fade and slide
.fadeAndSlide(edge: .bottom)
```

### Slide Animations

```swift
// Slide in from edge
.slideIn(from: .leading, delay: 0.1)
```

### Card Animations

```swift
// Card appear with scale
.cardAppear(delay: 0.1)
```

### Special Effects

```swift
// Shimmer effect (for loading)
.shimmer()

// Shake animation (for errors)
.shake(trigger: errorCount)
```

### Staggered Lists

```swift
// In a ForEach:
ForEach(Array(items.enumerated()), id: \.offset) { index, item in
    ItemView(item: item)
        .staggeredAnimation(index: index, total: items.count)
}
```

---

## 🎯 Button Styles

### PressableButtonStyle

```swift
Button("Press me") { }
    .buttonStyle(PressableButtonStyle(haptic: .medium))
```

**Features:**
- 0.95x scale on press
- Opacity change
- Configurable haptic

### CardButtonStyle

```swift
Button("Tap me") { }
    .buttonStyle(CardButtonStyle())
```

**Features:**
- 0.97x scale on press
- Light haptic
- Snappy animation

---

## 🔄 Tab View Animations

### EnhancedMainTabView

Custom tab bar with smooth transitions:

```swift
EnhancedMainTabView()
    .environmentObject(userVM)
    .environmentObject(tasksVM)
```

**Features:**
- Smooth slide transitions between tabs
- Matched geometry effect for selection indicator
- Selection haptic feedback
- Frosted glass tab bar
- Icons scale and change weight on selection

---

## 📱 Usage Examples

### Example 1: Task Card in Feed

```swift
ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
    EnhancedTaskCardView(task: task, index: index) {
        // Navigate to detail
    }
    .staggeredAnimation(index: index, total: tasks.count)
}
```

**Result**: Cards fade in from bottom with stagger effect, haptic on tap

---

### Example 2: Success After Payment

```swift
if showSuccess {
    AnimatedSuccessOverlay(
        title: "Payment Successful!",
        message: "Your payment has been processed"
    ) {
        showSuccess = false
    }
}
```

**Result**: Checkmark animates in, success haptic plays, bouncy animation

---

### Example 3: Button with Loading

```swift
AnimatedPrimaryButton(
    "Submit",
    icon: "checkmark.circle.fill",
    isLoading: isSubmitting,
    isDisabled: !formIsValid
) {
    submitForm()
}
```

**Result**: Button animates on press, shows spinner when loading, haptic feedback

---

### Example 4: Rating Provider

```swift
VStack {
    Text("Rate this provider")

    AnimatedStarRating(rating: $rating, interactive: true)
}
```

**Result**: Stars bounce when tapped, light haptic for each star

---

## 🎨 Animation Timing Reference

| Animation | Duration | Damping | Feel |
|-----------|----------|---------|------|
| Smooth | 0.4s | 0.8 | Natural, comfortable |
| Bouncy | 0.5s | 0.6 | Playful, energetic |
| Snappy | 0.3s | 0.85 | Quick, responsive |
| Gentle | 0.6s | 0.9 | Subtle, elegant |
| Button Press | 0.2s | 0.7 | Fast, tight |
| Modal | 0.45s | 0.82 | Smooth presentation |
| Tab Switch | 0.35s | 0.85 | Crisp transition |

---

## 📳 Haptic Timing Reference

| Pattern | Haptics | Timing |
|---------|---------|--------|
| Button Press | Medium | Instant |
| Task Completed | Medium → Success | 0.1s delay |
| Payment Success | Heavy → Success → Light | 0.1s, 0.2s delays |
| Destructive | Heavy → Error | 0.1s delay |
| Card Flip | Medium → Light | 0.15s delay |
| Toggle | Soft | Instant |
| Selection | Selection feedback | Instant |

---

## 🎯 Best Practices

### DO ✅

- Use `AnimationPresets.smooth` for most transitions
- Match haptic intensity to action importance
- Stagger list animations (0.05s per item)
- Keep button press animations quick (0.2s)
- Use success haptics for completions
- Scale buttons to 0.95-0.97x on press

### DON'T ❌

- Overuse heavy haptics (jarring)
- Animate everything (overwhelming)
- Use long animations (>0.6s feels slow)
- Skip haptics on important actions
- Mix animation styles inconsistently
- Forget to disable haptics in settings (if needed)

---

## 🔧 Customization

### Create Custom Animation

```swift
let myAnimation = Animation.spring(
    response: 0.4,      // Duration feel
    dampingFraction: 0.8, // Bounciness (lower = more bounce)
    blendDuration: 0
)
```

### Create Custom Haptic Pattern

```swift
extension HapticsManager {
    func myCustomPattern() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.light()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.success()
        }
    }
}
```

---

## 📊 Performance Tips

1. **Animate Value, Not ID**: Use `.animation(.smooth, value: count)` not `.animation(.smooth)`
2. **Prefer withAnimation**: More control, better performance
3. **Limit Simultaneous Animations**: Max 10-15 items animating at once
4. **Use Staggered Delays**: Better than all at once
5. **Test on Real Device**: Simulator haptics don't work!

---

## 🎬 Migration Guide

### Replace Standard Buttons

**Before:**
```swift
Button("Post") {
    postTask()
}
.buttonStyle(.borderedProminent)
```

**After:**
```swift
AnimatedPrimaryButton("Post", icon: "plus.circle.fill") {
    postTask()
}
```

### Replace Standard Cards

**Before:**
```swift
VStack {
    Text("Task")
}
.background(Color.gray)
.cornerRadius(12)
```

**After:**
```swift
AnimatedCard {
    Text("Task")
}
```

### Add Haptics to Existing Buttons

**Before:**
```swift
Button("Delete") {
    delete()
}
```

**After:**
```swift
Button("Delete") {
    HapticsManager.shared.destructive()
    delete()
}
```

---

Your app now has **premium, buttery-smooth animations** and **satisfying haptic feedback** just like Opal! 🎨✨📳

Every interaction feels responsive, polished, and delightful.
