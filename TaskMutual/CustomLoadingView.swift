//
//  CustomLoadingView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/25/25.
//


import SwiftUI

// 1. GLASSY Blur for your loading card
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// 2. FAST SHIMMER for your logo
struct FastShimmer: ViewModifier {
    @State private var phase: CGFloat = -1.0
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [
                    Color.white.opacity(0.10),
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase * 200)
                .blendMode(.plusLighter)
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 0.85).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
    }
}

extension View {
    func fastShimmer() -> some View { self.modifier(FastShimmer()) }
}

// 3. ANIMATED LOADING TEXT with dots
struct AnimatedLoadingText: View {
    @State private var dotCount = 0
    let baseText: String
    var body: some View {
        Text(baseText + String(repeating: ".", count: dotCount))
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundColor(Color.white.opacity(0.92)) // more solid
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in
                    dotCount = (dotCount + 1) % 4
                }
            }
            .animation(.easeOut, value: dotCount)
    }
}

// 4. MAIN LOADING VIEW WITH GLASSY CARD + LOGO + SHIMMER + LOADING TEXT
struct CustomLoadingView: View {
    @State private var logoScale: CGFloat = 0.93
    var body: some View {
        ZStack {
            // --- Gradient background: replace with your brand color set names or .purple/.blue ---
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BrandAccent"), Color("AppBackground")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 32) {
                // --- LOGO with shimmer effect and bounce ---
                Image("AppLogo") // <-- Change to your asset!
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .scaleEffect(logoScale)
                    .shadow(color: Color.black.opacity(0.16), radius: 13, x: 0, y: 6)
                    .fastShimmer()
                    .onAppear {
                        withAnimation(
                            .interpolatingSpring(stiffness: 180, damping: 10).repeatForever(autoreverses: true)
                        ) {
                            logoScale = 1.07
                        }
                    }

                // --- Animated loading message ---
                AnimatedLoadingText(baseText: "Matching you with the right TaskMutuals")

                // (Optional secondary text)
                Text("This won’t take long")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                Color.black.opacity(0.42) // <-- add this for a dark glass effect
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        BlurView(style: .systemMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.13), lineWidth: 2)
                    )
            )
            .padding(.horizontal, 36)
        }
    }
}
