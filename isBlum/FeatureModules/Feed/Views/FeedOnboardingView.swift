import SwiftUI

struct FeedOnboardingView: View {
    let onDismiss: () -> Void

    @State private var currentStep = 0
    @State private var fingerY: CGFloat = 0
    @State private var fingerOpacity: Double = 1
    @State private var trailProgress: CGFloat = 0
    @State private var tapScale: CGFloat = 1
    @State private var animLoop: Task<Void, Never>?

    // Gesture feedback
    @State private var gestureSuccess = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Animation area
                ZStack {
                    switch currentStep {
                    case 0: swipeUpAnimation
                    case 1: swipeDownAnimation
                    default: tapAnimation
                    }
                }
                .frame(height: 260)

                Spacer().frame(height: 36)

                // Text
                VStack(spacing: 10) {
                    Text(stepTitle)
                        .font(.onest(.bold, size: 24))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text(stepSubtitle)
                        .font(.onest(.regular, size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer().frame(height: 40)

                // Step dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i == currentStep ? Color(hex: "9AF19A") : Color.gray.opacity(0.25))
                            .frame(width: i == currentStep ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                    }
                }

                Spacer()
            }
        }
        // Swipe up — step 0
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { val in
                    let isVertical = abs(val.translation.height) > abs(val.translation.width)
                    guard isVertical else { return }
                    if currentStep == 0 && val.translation.height < -50 {
                        advance()
                    } else if currentStep == 1 && val.translation.height > 50 {
                        advance()
                    }
                }
        )
        // Tap — step 2
        .simultaneousGesture(
            TapGesture().onEnded {
                if currentStep == 2 { advance() }
            }
        )
        .onAppear {
            startLoop()
        }
        .onDisappear {
            animLoop?.cancel()
        }
        .onChange(of: currentStep) { _ in
            startLoop()
        }
    }

    // MARK: - Swipe Up Animation

    private var swipeUpAnimation: some View {
        ZStack(alignment: .center) {

            // Trail below finger (fades as finger moves up)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "9AF19A").opacity(0.7), Color.clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 16, height: 196 * trailProgress)
                .offset(y: fingerY + 60 * trailProgress)
                .opacity(trailProgress)

            // Finger
            Image(.gestureIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .offset(y: fingerY)
                .opacity(fingerOpacity)
        }
    }

    // MARK: - Swipe Down Animation

    private var swipeDownAnimation: some View {
        ZStack(alignment: .center) {

            // Trail above finger
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "9AF19A").opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 16, height: 196 * trailProgress)
                .offset(y: fingerY - 60 * trailProgress)
                .opacity(trailProgress)

            // Finger (flipped vertically for downward swipe)
            Image(.gestureIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .scaleEffect(y: -1)
                .offset(y: fingerY)
                .opacity(fingerOpacity)
        }
    }

    // MARK: - Tap Animation

    private var tapAnimation: some View {
        ZStack {
            // The mock "Переглянути" button
            Circle()
                .fill(Color.white)
                .frame(width: 64, height: 64)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                .overlay(
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "9AF19A"))
                )

            // Finger approaching and tapping
            Image(.gestureIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(20))
                .offset(x: 20, y: fingerY)
                .opacity(fingerOpacity)
                .scaleEffect(tapScale)
        }
    }

    // MARK: - Animation Loop

    private func startLoop() {
        animLoop?.cancel()
        fingerY = 0
        trailProgress = 0
        fingerOpacity = 1
        tapScale = 1

        animLoop = Task {
            while !Task.isCancelled {
                switch currentStep {
                case 0: await runSwipeUpLoop()
                case 1: await runSwipeDownLoop()
                default: await runTapLoop()
                }
                guard !Task.isCancelled else { return }
            }
        }
    }

    // Swipe up loop: finger moves from bottom to top
    private func runSwipeUpLoop() async {
        // Reset to start position (no animation)
        fingerY = 50
        trailProgress = 0
        fingerOpacity = 1

        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s pause
        guard !Task.isCancelled else { return }

        // Move up + trail grows
        withAnimation(.easeInOut(duration: 0.7)) {
            fingerY = -90
            trailProgress = 1
        }
        try? await Task.sleep(nanoseconds: 750_000_000)
        guard !Task.isCancelled else { return }

        // Fade out at top
        withAnimation(.easeOut(duration: 0.25)) {
            fingerOpacity = 0
            trailProgress = 0
        }
        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }

        fingerOpacity = 1
    }

    // Swipe down loop: finger moves from top to bottom
    private func runSwipeDownLoop() async {
        fingerY = -50
        trailProgress = 0
        fingerOpacity = 1

        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }

        withAnimation(.easeInOut(duration: 0.7)) {
            fingerY = 90
            trailProgress = 1
        }
        try? await Task.sleep(nanoseconds: 750_000_000)
        guard !Task.isCancelled else { return }

        withAnimation(.easeOut(duration: 0.25)) {
            fingerOpacity = 0
            trailProgress = 0
        }
        try? await Task.sleep(nanoseconds: 300_000_000)
        guard !Task.isCancelled else { return }

        fingerOpacity = 1
    }

    // Tap loop: finger approaches button and taps
    private func runTapLoop() async {
        fingerY = 60
        fingerOpacity = 0
        tapScale = 1

        // Finger appears from below and moves to button
        withAnimation(.easeOut(duration: 0.4)) {
            fingerOpacity = 1
            fingerY = 30
        }
        try? await Task.sleep(nanoseconds: 450_000_000)
        guard !Task.isCancelled else { return }

        // Tap (compress)
        withAnimation(.easeIn(duration: 0.12)) {
            tapScale = 0.75
        }
        try? await Task.sleep(nanoseconds: 130_000_000)
        guard !Task.isCancelled else { return }

        // Release
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            tapScale = 1
        }
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard !Task.isCancelled else { return }

        // Fade out and retreat
        withAnimation(.easeIn(duration: 0.25)) {
            fingerOpacity = 0
            fingerY = 60
        }
        try? await Task.sleep(nanoseconds: 400_000_000)
        guard !Task.isCancelled else { return }
    }

    // MARK: - Step Logic

    private func advance() {
        animLoop?.cancel()
        let next = currentStep + 1
        guard next <= 2 else {
            onDismiss()
            return
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = next
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case 0: return "Прокрутіть вгору"
        case 1: return "Прокрутіть вниз"
        default: return "Натисніть «Переглянути»"
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case 0: return "Щоб пропустити букет"
        case 1: return "Щоб повернутися до попереднього букету"
        default: return "Щоб відкрити деталі букету"
        }
    }
}
