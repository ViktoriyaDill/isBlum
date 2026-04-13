import SwiftUI

struct FeedSkeletonView: View {
    @State private var shimmerOpacity: Double = 0.4

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Large image placeholder filling most of screen
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.35))
                    .ignoresSafeArea()
                    .overlay(alignment: .bottomLeading) {
                        // Bottom content placeholders
                        VStack(alignment: .leading, spacing: 12) {
                            // Title placeholder
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 220, height: 22)

                            // Price placeholder
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 100, height: 18)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        // Seller avatar placeholder
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 48, height: 48)

                            // Button placeholder
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 52, height: 52)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 70)
                    }
            }
        }
        .opacity(shimmerOpacity)
        .animation(
            .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
            value: shimmerOpacity
        )
        .onAppear {
            shimmerOpacity = 0.7
        }
    }
}
