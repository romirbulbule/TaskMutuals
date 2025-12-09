# Complete Guide: Setting Up In-App Purchases for TaskMutuals

This guide will walk you through setting up Apple In-App Purchases with RevenueCat for TaskMutuals.

---

## Prerequisites

- **Apple Developer Account** ($99/year enrollment required)
- **Bundle ID**: `TaskMutuals.Project.TaskMutuals`
- **Xcode** with your project open

---

## Part 1: Apple Developer Portal Setup

### 1.1 Create App Identifier (if not already done)

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Click **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** (plus button)
4. Select **App IDs** → Click **Continue**
5. Select **App** → Click **Continue**
6. Fill in:
   - **Description**: TaskMutuals
   - **Bundle ID**: `TaskMutuals.Project.TaskMutuals` (Explicit)
7. Under **Capabilities**, check:
   - ✅ **In-App Purchase**
   - ✅ **Push Notifications** (you already use this)
8. Click **Continue** → **Register**

---

## Part 2: App Store Connect Setup

### 2.1 Create Your App (if not already created)

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** (plus button) → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: TaskMutuals
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `TaskMutuals.Project.TaskMutuals`
   - **SKU**: `taskmutuals` (or any unique identifier)
   - **User Access**: Full Access
4. Click **Create**

### 2.2 Create In-App Purchase Products

Now create all 3 products your code expects:

---

#### **Product 1: Seeker Premium Monthly**

1. In your app, go to **Features** → **In-App Purchases**
2. Click **+** (plus button)
3. Select **Auto-Renewable Subscription**
4. Click **Create**

**Subscription Group:**
- Click **Create New Subscription Group**
- **Reference Name**: Seeker Subscriptions
- Click **Create**

**Product Information:**
- **Reference Name**: Seeker Premium Monthly
- **Product ID**: `seeker_premium_monthly` ⚠️ **Must match exactly!**
- **Subscription Duration**: 1 Month

**Subscription Prices:**
- Click **Add Subscription Pricing**
- **Price**: $14.99 USD
- **Start Date**: Today
- Click **Next** → **Create**

**App Store Localization:**
- Click **+ Add Localization**
- **Language**: English (U.S.)
- **Subscription Display Name**: Premium
- **Description**: Unlimited task posts, priority matching, featured listings, advanced analytics, and priority support.
- Click **Save**

**Review Information:**
- **Screenshot**: Upload any app screenshot (required for review)
- Click **Save**

5. Click **Save** at the top

---

#### **Product 2: Provider Verified (One-Time)**

1. Click **+** (plus button)
2. Select **Non-Consumable**
3. Click **Create**

**Product Information:**
- **Reference Name**: Provider Verified
- **Product ID**: `provider_verified_lifetime` ⚠️ **Must match exactly!**

**Pricing:**
- Click **Add Pricing**
- **Price**: $49.99 USD
- Click **Next** → **Create**

**App Store Localization:**
- Click **+ Add Localization**
- **Language**: English (U.S.)
- **Display Name**: Verified Provider
- **Description**: Get verified badge, featured profile, priority in search results, and reduced 12% transaction fee. One-time payment.
- Click **Save**

**Review Information:**
- **Screenshot**: Upload any app screenshot
- Click **Save**

3. Click **Save** at the top

---

#### **Product 3: Provider Pro Yearly**

1. Click **+** (plus button)
2. Select **Auto-Renewable Subscription**
3. Click **Create**

**Subscription Group:**
- Click **Create New Subscription Group**
- **Reference Name**: Provider Subscriptions
- Click **Create**

**Product Information:**
- **Reference Name**: Provider Pro Yearly
- **Product ID**: `provider_pro_yearly` ⚠️ **Must match exactly!**
- **Subscription Duration**: 1 Year

**Subscription Prices:**
- Click **Add Subscription Pricing**
- **Price**: $149.99 USD
- **Start Date**: Today
- Click **Next** → **Create**

**App Store Localization:**
- Click **+ Add Localization**
- **Language**: English (U.S.)
- **Subscription Display Name**: Pro Provider
- **Description**: Pro badge, premium featured profile, top priority in search, 10% transaction fee, advanced analytics, and priority support.
- Click **Save**

**Review Information:**
- **Screenshot**: Upload any app screenshot
- Click **Save**

5. Click **Save** at the top

---

### 2.3 Set Products to "Ready to Submit"

For each of the 3 products:
1. Open the product
2. Make sure all sections have green checkmarks
3. Status should show **"Ready to Submit"**

⚠️ **Important:** Products won't work until they're "Ready to Submit" status!

---

## Part 3: RevenueCat Setup

### 3.1 Create RevenueCat Account

1. Go to [RevenueCat](https://app.revenuecat.com/signup)
2. Sign up with your email
3. Verify your email
4. Create new project:
   - **Project Name**: TaskMutuals
   - **Platform**: iOS
   - Click **Create**

### 3.2 Connect App Store

1. In RevenueCat dashboard, go to **Project Settings** → **Apple App Store**
2. You'll need to connect your App Store Connect account:
   - Click **Set up App Store Connect API**
   - Follow instructions to create an API Key in App Store Connect
   - Go to [App Store Connect Users and Access](https://appstoreconnect.apple.com/access/api)
   - Click **Keys** tab → **+** (Generate API Key)
   - **Name**: RevenueCat
   - **Access**: App Manager
   - Click **Generate**
   - Download the `.p8` file (you can only download once!)
   - Copy the **Key ID** and **Issuer ID**
3. Back in RevenueCat:
   - Upload the `.p8` file
   - Enter **Key ID**
   - Enter **Issuer ID**
   - Click **Save**

### 3.3 Get Your API Key

1. In RevenueCat, go to **Project Settings** → **API Keys**
2. Find the **Apple App Store** section
3. Copy your API key (starts with `appl_...`)
4. **Save this key** - you'll need it in Part 5

---

## Part 4: Configure Products in RevenueCat

### 4.1 Add Products

1. In RevenueCat dashboard, go to **Products**
2. Click **+ New**

**Product 1:**
- **App Store Product Identifier**: `seeker_premium_monthly`
- **Type**: Subscription
- **Duration**: 1 Month
- Click **Add**

3. Click **+ New** again

**Product 2:**
- **App Store Product Identifier**: `provider_verified_lifetime`
- **Type**: Non-Subscription
- Click **Add**

4. Click **+ New** again

**Product 3:**
- **App Store Product Identifier**: `provider_pro_yearly`
- **Type**: Subscription
- **Duration**: 1 Year
- Click **Add**

You should now see all 3 products listed.

---

### 4.2 Create Entitlements

1. Go to **Entitlements** → **+ New**

**Entitlement 1:**
- **Identifier**: `seeker_premium` ⚠️ **Must match exactly!**
- Click **Create**
- Click **Attach** → Select `seeker_premium_monthly`
- Click **Attach Products**

2. Click **+ New**

**Entitlement 2:**
- **Identifier**: `provider_verified` ⚠️ **Must match exactly!**
- Click **Create**
- Click **Attach** → Select `provider_verified_lifetime`
- Click **Attach Products**

3. Click **+ New**

**Entitlement 3:**
- **Identifier**: `provider_pro` ⚠️ **Must match exactly!**
- Click **Create**
- Click **Attach** → Select `provider_pro_yearly`
- Click **Attach Products**

---

### 4.3 Create Offering

1. Go to **Offerings** → **+ New Offering**
2. **Offering Identifier**: `default` (or leave default)
3. Check **Make this the current offering**
4. Click **Create**
5. Now add packages:

**Package 1:**
- Click **+ Add Package**
- **Identifier**: `monthly`
- **Product**: Select `seeker_premium_monthly`
- Click **Add**

**Package 2:**
- Click **+ Add Package**
- **Identifier**: `verified`
- **Product**: Select `provider_verified_lifetime`
- Click **Add**

**Package 3:**
- Click **+ Add Package**
- **Identifier**: `yearly`
- **Product**: Select `provider_pro_yearly`
- Click **Add**

6. Click **Save**

---

## Part 5: Update Your Code

### 5.1 Update API Key in PurchaseManager

1. Open `TaskMutual/Subscription/PurchaseManager.swift`
2. Find line 30 (the `configure()` function)
3. Replace the test API key with your RevenueCat API key from Part 3.3:

```swift
Purchases.configure(withAPIKey: "appl_YOUR_KEY_HERE")
```

Replace `appl_YOUR_KEY_HERE` with your actual RevenueCat API key.

4. Save the file

---

## Part 6: Xcode Configuration

### 6.1 Add In-App Purchase Capability

1. Open `TaskMutual.xcodeproj` in Xcode
2. Select your project in the navigator
3. Select the **TaskMutual** target
4. Click **Signing & Capabilities** tab
5. Click **+ Capability**
6. Search for and add **In-App Purchase**
7. Make sure **Automatically manage signing** is enabled
8. Select your **Team** (your Apple Developer account)

### 6.2 Verify RevenueCat Package

1. In Xcode, go to **File** → **Packages** → **Resolve Package Versions**
2. Make sure RevenueCat package is installed
3. If not, add it:
   - **File** → **Add Package Dependencies**
   - URL: `https://github.com/RevenueCat/purchases-ios.git`
   - Version: Up to Next Major (recommended)
   - Click **Add Package**

---

## Part 7: Create Sandbox Test Account

### 7.1 Create Test Account in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **Users and Access**
3. Click **Sandbox** tab
4. Click **Testers** → **+** (plus button)
5. Fill in:
   - **First Name**: Test
   - **Last Name**: User
   - **Email**: Create a new email (can't be your Apple ID)
     - Example: `taskmutuals.test@gmail.com`
   - **Password**: Create a strong password
   - **Confirm Password**: Same password
   - **Country/Region**: United States
   - **App Store Territory**: United States
6. Click **Invite**
7. **Save these credentials** - you'll need them for testing!

**Test Account Credentials (write them down):**
- Email: ___________________________
- Password: ___________________________

---

## Part 8: Testing on Device

### 8.1 Prepare Your Test Device

1. On your iPhone/iPad, **sign out of App Store**:
   - Go to **Settings** → **[Your Name]** → **Media & Purchases**
   - Tap **Sign Out**
   - (Don't sign out of iCloud, just Media & Purchases!)

### 8.2 Build and Install App

1. Connect your device to your Mac
2. In Xcode, select your device as the target
3. Click **Product** → **Run** (or press ⌘R)
4. Wait for the app to install and launch

### 8.3 Test Purchase Flow

1. Open the app on your device
2. Sign in or create a test account
3. Navigate to where you can upgrade:
   - Go to **Profile** tab → Tap on subscription/premium option
   - OR post 7 tasks to trigger the limit, then try posting an 8th
4. Tap **"Start Premium - $14.99/month"**
5. Apple's purchase sheet should appear
6. When prompted to sign in:
   - **Use your sandbox test account credentials** (from Part 7)
   - Don't use your real Apple ID!
7. Confirm the purchase
8. In sandbox mode, **purchases are FREE** - you won't be charged
9. The purchase should complete
10. Verify Premium features unlock (unlimited tasks, etc.)

### 8.4 Test Restore Purchases

1. In the subscription view, tap **"Restore Purchases"**
2. Should restore your Premium status
3. Check that features remain unlocked

---

## Part 9: Verify Everything Works

### Checklist:

- [ ] Products show up in the app
- [ ] Purchase sheet appears when tapping upgrade
- [ ] Purchase completes successfully
- [ ] Premium features unlock (check task limit removed)
- [ ] Restore purchases works
- [ ] No errors in Xcode console

### Expected Console Messages:

```
✅ RevenueCat configured
✅ Fetched offerings: 3 packages
✅ Purchase successful! Tier: Premium, Expiry: ...
✅ Subscription status: Premium
```

---

## Part 10: Going to Production

### When ready to submit to App Review:

1. **Archive your app**:
   - Xcode → **Product** → **Archive**
   - **Distribute App** → **App Store Connect**

2. **Submit for review**:
   - In App Store Connect, fill out app information
   - Add screenshots
   - IAP products should be "Ready to Submit"
   - Submit app + IAPs together

3. **Include sandbox test account** for reviewers:
   - In App Store Connect → **App Review Information**
   - Add your sandbox test credentials
   - This lets Apple test purchases during review

4. **RevenueCat automatically detects production**:
   - No code changes needed
   - Production purchases will be processed automatically

---

## Troubleshooting

### "No products available"
- Wait 2-4 hours after creating products in App Store Connect
- Verify product IDs match exactly (case-sensitive)
- Check products are "Ready to Submit" status
- Clear DerivedData: Xcode → **Product** → **Clean Build Folder**
- Check internet connection

### "Purchase failed"
- Make sure you're signed out of App Store on device
- Use sandbox test account (not your real Apple ID)
- Verify In-App Purchase capability is enabled in Xcode
- Check internet connection
- Try restarting the app

### "Cannot connect to App Store"
- Check device has internet
- Try restarting device
- Sign out and sign back in to sandbox account
- Check firewall/VPN settings

### Products not appearing in RevenueCat
- Wait 24 hours for App Store Connect sync
- Verify API key connection is working
- Check products were created with exact IDs
- Verify entitlements are properly attached

### RevenueCat errors in console
- Check API key is correct in PurchaseManager.swift
- Verify RevenueCat package is properly installed
- Check internet connection
- Look for specific error messages and search RevenueCat docs

---

## Quick Reference: Product IDs

Make sure these match **EXACTLY** everywhere (case-sensitive):

| Tier | Product ID | Type | Price | Entitlement ID |
|------|-----------|------|-------|----------------|
| Seeker Premium | `seeker_premium_monthly` | Auto-Renewable (1 month) | $14.99 | `seeker_premium` |
| Provider Verified | `provider_verified_lifetime` | Non-Consumable | $49.99 | `provider_verified` |
| Provider Pro | `provider_pro_yearly` | Auto-Renewable (1 year) | $149.99 | `provider_pro` |

---

## Resources

- [RevenueCat Documentation](https://www.revenuecat.com/docs)
- [Apple IAP Guide](https://developer.apple.com/in-app-purchase/)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Portal](https://developer.apple.com/account)
- [RevenueCat Dashboard](https://app.revenuecat.com)

---

## Estimated Time

- **Part 1-2 (Apple setup)**: 30-45 minutes
- **Part 3-4 (RevenueCat setup)**: 30-45 minutes
- **Part 5-6 (Code configuration)**: 15 minutes
- **Part 7-9 (Testing)**: 30 minutes
- **Total**: 2-3 hours

---

## Notes

- All product IDs and entitlement IDs are **case-sensitive**
- Products must be "Ready to Submit" in App Store Connect
- Sandbox purchases are free and instant
- Wait 2-4 hours after creating products before testing
- Keep your sandbox test credentials safe
- RevenueCat is free up to $10k/month in revenue

---

**Good luck with your setup! Once complete, your in-app purchases will work on all devices.**

For questions, check the [RevenueCat Community](https://community.revenuecat.com) or [Apple Developer Forums](https://developer.apple.com/forums/).
