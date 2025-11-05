# TaskMutuals Color Setup Guide

This guide will help you set up the app colors to match your app icon in both Light and Dark modes.

## 🎨 Color Palette (from App Icon)

- **Forest Green**: `#2C4F41` (RGB: 44, 79, 65)
- **Cream/Beige**: `#F5EDE4` (RGB: 245, 237, 228)

---

## 📱 Setup Instructions in Xcode

### 1. Open Assets.xcassets
1. In Xcode, open your project
2. Navigate to **Assets.xcassets** (or **TaskMutual/Assets.xcassets**)
3. You'll add Color Sets for each color below

### 2. Add Color Sets

For each color below, right-click in the assets panel and select **"New Color Set"**:

---

### **BrandGreen** (Forest Green)
- **Any Appearance (Light Mode)**:
  - RGB: `44, 79, 65`
  - Hex: `#2C4F41`
- **Dark Appearance**:
  - RGB: `60, 90, 75`
  - Hex: `#3C5A4B` (slightly lighter for visibility)

---

### **BrandCream** (Cream/Beige)
- **Any Appearance (Light Mode)**:
  - RGB: `245, 237, 228`
  - Hex: `#F5EDE4`
- **Dark Appearance**:
  - RGB: `230, 220, 210`
  - Hex: `#E6DCD2` (slightly muted for eye comfort)

---

### **AppBackground** (Main app background)
- **Any Appearance (Light Mode)**:
  - RGB: `245, 237, 228` (Cream - matches icon center)
  - Hex: `#F5EDE4`
- **Dark Appearance**:
  - RGB: `44, 79, 65` (Forest Green - matches icon background)
  - Hex: `#2C4F41`

---

### **AppSurface** (Cards and elevated surfaces)
- **Any Appearance (Light Mode)**:
  - RGB: `255, 253, 250` (Warm white)
  - Hex: `#FFFDFA`
- **Dark Appearance**:
  - RGB: `52, 89, 73` (Lighter than background)
  - Hex: `#345949`

---

### **BrandAccent** (Primary interactive elements)
- **Any Appearance (Light Mode)**:
  - RGB: `44, 79, 65` (Forest Green for good contrast on light background)
  - Hex: `#2C4F41`
- **Dark Appearance**:
  - RGB: `245, 237, 228` (Cream for good contrast on dark background)
  - Hex: `#F5EDE4`

---

### **SecondaryAccent** (Secondary interactive elements)
- **Any Appearance (Light Mode)**:
  - RGB: `70, 115, 95`
  - Hex: `#46735F` (Medium green)
- **Dark Appearance**:
  - RGB: `215, 205, 195`
  - Hex: `#D7CDC3` (Muted cream)

---

### **TextPrimary** (Primary text)
- **Any Appearance (Light Mode)**:
  - RGB: `35, 60, 50`
  - Hex: `#233C32` (Very dark green)
- **Dark Appearance**:
  - RGB: `245, 237, 228`
  - Hex: `#F5EDE4` (Cream)

---

### **TextSecondary** (Secondary text)
- **Any Appearance (Light Mode)**:
  - RGB: `70, 115, 95` with 80% opacity
  - Hex: `#46735F` + 80% opacity
- **Dark Appearance**:
  - RGB: `230, 220, 210` with 80% opacity
  - Hex: `#E6DCD2` + 80% opacity

---

### **TextTertiary** (Tertiary text - captions)
- **Any Appearance (Light Mode)**:
  - RGB: `70, 115, 95` with 60% opacity
  - Hex: `#46735F` + 60% opacity
- **Dark Appearance**:
  - RGB: `230, 220, 210` with 60% opacity
  - Hex: `#E6DCD2` + 60% opacity

---

### **SuccessColor** (Success messages, completed tasks)
- **Any Appearance (Light Mode)**:
  - RGB: `52, 125, 90`
  - Hex: `#347D5A` (Brighter green)
- **Dark Appearance**:
  - RGB: `76, 175, 130`
  - Hex: `#4CAF82` (Even brighter for visibility)

---

### **WarningColor** (Warnings, pending actions)
- **Any Appearance (Light Mode)**:
  - RGB: `215, 140, 60`
  - Hex: `#D78C3C`
- **Dark Appearance**:
  - RGB: `235, 165, 90`
  - Hex: `#EBA55A`

---

### **ErrorColor** (Errors, destructive actions)
- **Any Appearance (Light Mode)**:
  - RGB: `200, 65, 65`
  - Hex: `#C84141`
- **Dark Appearance**:
  - RGB: `220, 95, 95`
  - Hex: `#DC5F5F`

---

### **InfoColor** (Information, hints)
- **Any Appearance (Light Mode)**:
  - RGB: `70, 115, 140`
  - Hex: `#46738C` (Blue-green)
- **Dark Appearance**:
  - RGB: `110, 165, 195`
  - Hex: `#6EA5C3`

---

## 🔧 How to Add a Color Set in Xcode

1. **Right-click** in the Assets.xcassets panel
2. Select **"Color Set"** from the menu
3. **Name it** exactly as shown above (e.g., "BrandGreen")
4. **Click on the color square** to open the color picker
5. In the **Attributes Inspector** (right panel), set **Appearances** to **"Any, Dark"**
6. Set the **"Any Appearance"** color (this is Light Mode)
   - Switch to **RGB Sliders** in color picker
   - Enter the RGB values
7. Set the **"Dark Appearance"** color
   - Click on the dark color square
   - Enter the Dark Mode RGB values

---

## 🎯 Existing Color Names

If you already have these color names in your Assets, you can simply **update their values**:
- `BrandBackground` → Update or rename to `AppBackground`
- `BrandAccent` → Update with new values

---

## ✅ Testing

After adding all colors:
1. Run your app in the **Simulator**
2. Test both **Light Mode** and **Dark Mode**:
   - iOS: **Settings → Developer → Dark Appearance**
   - Or: **Simulator → Features → Toggle Appearance**
3. Verify that all screens look good in both modes

---

## 🌟 Color Philosophy

**Light Mode**: Clean and warm with cream backgrounds, dark green accents
- Like the **center of your app icon** (cream square)
- Easy on the eyes, professional feel

**Dark Mode**: Rich and sophisticated with forest green backgrounds, cream accents
- Like the **background of your app icon** (dark green)
- Perfect for evening use, reduces eye strain

---

## 📋 Quick Copy-Paste Values

```
Forest Green (Light): #2C4F41 (44, 79, 65)
Forest Green (Dark):  #3C5A4B (60, 90, 75)
Cream (Light):        #F5EDE4 (245, 237, 228)
Cream (Dark):         #E6DCD2 (230, 220, 210)
```

---

Your app will now have a beautiful, consistent theme that matches your gorgeous app icon! 🎨✨
