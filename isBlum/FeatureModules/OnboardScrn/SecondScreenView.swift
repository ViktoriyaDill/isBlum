//
//  SecondScreenView.swift
//  isBlum
//
//  Created by Пользователь on 12/02/2026.
//

import Foundation
import SwiftUI

struct FallingFlower: Identifiable {
    let id = UUID()
    let imageName: String
    let finalX: CGFloat
    let finalY: CGFloat
    let rotation: Double
    let delay: Double
}

struct OnboardingCardData: Identifiable {
    let id = UUID()
    let imageName: String
    let rotation: Double
}

struct SecondStepStaticView: View {
    private let cards = [
        OnboardingCardData(imageName: "onbordCard", rotation: -5),
        OnboardingCardData(imageName: "onbordCard1", rotation: 4),
        OnboardingCardData(imageName: "swipeCard2", rotation: -3),
        OnboardingCardData(imageName: "swipeCard3", rotation: 6)
    ]
    
    @State private var currentIndex = 0
    @State private var offset: CGFloat = 450
    @State private var opacity: Double = 0
    @State private var currentRotation: Double = 0
    @State private var floatingOffset: CGFloat = 0
    @State private var floatingRotation: Double = 0

    var body: some View {
        ZStack {
            if currentIndex < cards.count {
                VStack(spacing: 0) {
                    Image(cards[currentIndex].imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(10)
                }
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                .rotationEffect(.degrees(currentRotation + floatingRotation))
                .offset(y: offset + floatingOffset)
                .opacity(opacity)
                .onAppear {
                    runSequence()
                }
                .id(currentIndex)
            }
        }
    }

    private func runSequence() {
        let card = cards[currentIndex]
        
        withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) {
            offset = 0
            opacity = 1
            currentRotation = card.rotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                floatingOffset = -15
                floatingRotation = card.rotation > 0 ? -2 : 2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeIn(duration: 0.5)) {
                offset = -550
                opacity = 0
                currentRotation += card.rotation * 1.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                floatingOffset = 0
                floatingRotation = 0
                offset = 450
                
                if currentIndex < cards.count - 1 {
                    currentIndex += 1
                } else {
                    currentIndex = 0
                }
            }
        }
    }
}
