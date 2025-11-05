//
//  Theme.swift
//  TaskMutual
//
//  App-wide theme matching the TaskMutuals app icon
//  Color scheme: Forest Green & Cream/Beige
//

import SwiftUI

struct Theme {
    // MARK: - Primary Colors (matching app icon)

    /// Forest Green - Main brand color from app icon background
    /// Light mode: Rich forest green
    /// Dark mode: Slightly lighter for better visibility
    static let brandGreen = Color("BrandGreen")

    /// Cream/Beige - Accent color from app icon
    /// Light mode: Warm cream
    /// Dark mode: Slightly muted for eye comfort
    static let brandCream = Color("BrandCream")

    // MARK: - Background Colors

    /// Main background color
    /// Light mode: Cream/beige (matching icon center)
    /// Dark mode: Dark forest green (matching icon background)
    static let background = Color("AppBackground")

    /// Card/Surface background
    /// Light mode: White with slight warmth
    /// Dark mode: Lighter green than main background
    static let surface = Color("AppSurface")

    // MARK: - Accent & Interactive Colors

    /// Primary accent for buttons, links, and interactive elements
    /// Uses the cream color in dark mode, green in light mode for good contrast
    static let accent = Color("BrandAccent")

    /// Secondary accent for less prominent interactive elements
    static let secondaryAccent = Color("SecondaryAccent")

    // MARK: - Text Colors

    /// Primary text color (adapts to light/dark mode)
    static let textPrimary = Color("TextPrimary")

    /// Secondary text color (slightly dimmed)
    static let textSecondary = Color("TextSecondary")

    /// Tertiary text color (more dimmed, for captions)
    static let textTertiary = Color("TextTertiary")

    // MARK: - Semantic Colors

    /// Success/positive color (green-based to match brand)
    static let success = Color("SuccessColor")

    /// Warning/caution color
    static let warning = Color("WarningColor")

    /// Error/danger color
    static let error = Color("ErrorColor")

    /// Info color
    static let info = Color("InfoColor")
}

// MARK: - Color Extensions for Programmatic Colors

extension Theme {
    /// Forest Green color matching app icon (programmatic fallback)
    static func forestGreen(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ?
            Color(red: 60/255, green: 90/255, blue: 75/255) :  // Lighter in dark mode
            Color(red: 44/255, green: 79/255, blue: 65/255)     // #2C4F41
    }

    /// Cream/Beige color matching app icon (programmatic fallback)
    static func creamBeige(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ?
            Color(red: 230/255, green: 220/255, blue: 210/255) : // Slightly muted in dark mode
            Color(red: 245/255, green: 237/255, blue: 228/255)   // #F5EDE4
    }
}

// MARK: - Gradient Styles

extension Theme {
    /// Brand gradient for special UI elements
    static let brandGradient = LinearGradient(
        colors: [brandGreen, brandGreen.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Accent gradient for highlights
    static let accentGradient = LinearGradient(
        colors: [brandCream, brandCream.opacity(0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
