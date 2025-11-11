# RevenueCat + Apple IAP Setup Guide

This guide will help you set up Apple In-App Purchases with RevenueCat for TaskMutuals Premium subscription.

## 📋 Overview

TaskMutuals uses a hybrid payment approach:
- **RevenueCat + Apple IAP**: For Premium subscription ($14.99/month)
- **Stripe Connect** (future): For task payments between users

---

## ✅ What's Already Done

The code implementation is complete! Here's what's been set up:

### Files Created:
1. **`PurchaseManager.swift`** - Handles all IAP operations via RevenueCat
2. **Updated `SubscriptionView.swift`** - Real purchase flow with error handling
3. **Updated `TaskMutualApp.swift`** - RevenueCat configuration hook
4. **Updated `UserViewModel.swift`** - Subscription update method

### Features Implemented:
✅ Purchase Premium subscription
✅ Restore purchases
✅ Automatic subscription status checking
✅ Firestore integration (stores subscription data)
✅ 7 task/month limit for free users
✅ Unlimited tasks for Premium users
✅ Beautiful upgrade UI with pricing

---

## 🛠️ Setup Steps

### Step 1: Add RevenueCat Package to Xcode

1. Open `TaskMutual.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies**
3. Enter this URL: `https://github.com/RevenueCat/purchases-ios.git`
4. Click **Add Package**
5. Select **RevenueCat** library
6. Click **Add Package** again

### Step 2: Create RevenueCat Account

1. Go to [https://app.revenuecat.com/signup](https://app.revenuecat.com/signup)
2. Sign up for free account
3. Create a new project called "TaskMutuals"

### Step 3: Get RevenueCat API Key

1. In RevenueCat dashboard, go to **Project Settings > API Keys**
2. Copy your **Apple App Store** API key
3. Open `TaskMutual/Subscription/PurchaseManager.swift`
4. Replace `"YOUR_REVENUECAT_API_KEY_HERE"` with your actual key:

```swift
Purchases.configure(withAPIKey: "appl_XxXxXxXxXxXxXxX")
```

### Step 4: Create In-App Purchase Product in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app (create if you haven't already)
3. Go to **Features > In-App Purchases**
4. Click **+** to create new product
5. Select **Auto-Renewable Subscription**
6. Fill in details:
   - **Reference Name**: "Premium Monthly"
   - **Product ID**: `premium_monthly`
   - **Subscription Group**: Create new group called "Premium"
   - **Subscription Duration**: 1 month
   - **Price**: $14.99 USD
7. Add localizations (title, description)
8. Click **Save**

### Step 5: Configure RevenueCat Products

1. In RevenueCat dashboard, go to **Products**
2. Click **+ New** to add product
3. Enter details:
   - **App Store Product ID**: `premium_monthly`
   - **Type**: Subscription
4. Click **Save**

### Step 6: Create Entitlement in RevenueCat

1. Go to **Entitlements** in RevenueCat
2. Click **+ New**
3. Create entitlement with identifier: `premium`
4. Attach the `premium_monthly` product to this entitlement
5. Click **Save**

### Step 7: Create Offering in RevenueCat

1. Go to **Offerings** in RevenueCat
2. Click **+ New**
3. Make this the **Current Offering**
4. Add package:
   - **Identifier**: `monthly`
   - **Product**: `premium_monthly`
5. Click **Save**

### Step 8: Enable RevenueCat Configuration in App

1. Open `TaskMutual/TaskMutualApp.swift`
2. Uncomment this line:

```swift
init() {
    FirebaseApp.configure()

    // Uncomment this line ↓
    PurchaseManager.configure()

    // ... rest of init
}
```

### Step 9: Set Up Apple Pay Merchant ID (Required for IAP)

1. Go to [Apple Developer](https://developer.apple.com/account)
2. Go to **Certificates, IDs & Profiles > Identifiers**
3. Create **Merchant ID**: `merchant.com.yourname.taskmutual`
4. In Xcode, go to your target's **Signing & Capabilities**
5. Add **In-App Purchase** capability
6. Build and run!

---

## 🧪 Testing IAP in Sandbox

### Create Sandbox Test Account

1. Go to [App Store Connect > Users and Access](https://appstoreconnect.apple.com)
2. Go to **Sandbox > Testers**
3. Click **+** to create new tester
4. Use a **different email** than your Apple ID
5. Set country to **United States**

### Test on Device/Simulator

1. **On Device**: Sign out of App Store, use sandbox account when prompted
2. **On Simulator**: Sandbox testing works automatically in iOS 15+
3. Launch your app
4. Tap **Upgrade to Premium**
5. You should see the IAP purchase sheet
6. Complete purchase (free in sandbox)
7. Verify Premium features unlock

---

## 🎯 How It Works

### Purchase Flow:
```
User taps "Start Premium"
    ↓
PurchaseManager.purchasePremium()
    ↓
RevenueCat handles Apple IAP
    ↓
Returns subscription info (expiry date, etc.)
    ↓
Update Firestore with subscription
    ↓
User now has Premium access!
```

### Subscription Check:
```
App Launch
    ↓
PurchaseManager.checkSubscriptionStatus()
    ↓
RevenueCat checks with Apple servers
    ↓
Returns active/inactive status
    ↓
App updates UI accordingly
```

---

## 📱 What Users See

### Free Users:
- Banner in PostTaskView: "X tasks remaining this month"
- Alert when limit reached: "Upgrade to Premium for unlimited tasks"
- Upgrade button in banner

### Premium Users:
- No task limits
- No banner in PostTaskView
- Verified badge (future)
- No platform fees on first 3 tasks/month

---

## 🔍 Troubleshooting

### "No products available"
- Check Product ID matches exactly: `premium_monthly`
- Verify product is approved in App Store Connect
- Wait 2-4 hours after creating product

### "Purchase failed"
- Ensure sandbox tester is set up correctly
- Check device is using sandbox account
- Verify In-App Purchase capability is added

### "Subscription not updating in app"
- Check RevenueCat API key is correct
- Verify entitlement identifier is `premium`
- Check Firestore permissions

### Build Errors
If you see "Cannot find 'Purchases' in scope":
1. Make sure RevenueCat package was added (Step 1)
2. Clean build folder: **Product > Clean Build Folder**
3. Rebuild project

---

## 💰 Revenue & Analytics

RevenueCat provides a dashboard showing:
- Monthly recurring revenue (MRR)
- Active subscriptions
- Churn rate
- Trial conversions
- All free up to $10k/month!

Access at: [https://app.revenuecat.com](https://app.revenuecat.com)

---

## 🚀 Going Live

When ready to launch:

1. **App Store Review**:
   - IAP products must be in "Ready to Submit" status
   - Include test account credentials for reviewers
   - Explain Premium features in app description

2. **RevenueCat Production**:
   - RevenueCat automatically detects production vs sandbox
   - No changes needed in code

3. **Pricing Tiers**:
   - Start at $14.99/month
   - Can add annual plan later: $99.99/year (44% savings)

---

## 📚 Additional Resources

- [RevenueCat Docs](https://www.revenuecat.com/docs)
- [Apple IAP Guide](https://developer.apple.com/in-app-purchase/)
- [RevenueCat iOS Tutorial](https://www.revenuecat.com/docs/ios)

---

## ✨ Next Steps (Future Enhancements)

1. Add **annual subscription** option
2. Add **free trial** (7 days)
3. Implement **promotional offers** for returning users
4. Add **referral system** (give 1 month free per referral)
5. Integrate **Stripe Connect** for task payments

---

## 🆘 Need Help?

If you run into issues:
1. Check RevenueCat's [documentation](https://www.revenuecat.com/docs)
2. Join [RevenueCat Community](https://community.revenuecat.com)
3. Review Apple's [IAP best practices](https://developer.apple.com/app-store/subscriptions/)

---

**That's it!** Once you complete these steps, your Premium subscription system will be fully functional. Users can upgrade, and you'll start collecting revenue through Apple's payment system. RevenueCat makes it much easier than implementing StoreKit directly.

Good luck with your launch! 🚀
