//
//  ShimmeringLogo.swift
//  isBlum
//
//  Created by Пользователь on 09/02/2026.
//

import SwiftUI

struct ShimmeringLogo: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Image(.isblum)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 140)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.8), .clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                }
                .mask(Image(.isblum).resizable().scaledToFit())
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
            }
    }
}

