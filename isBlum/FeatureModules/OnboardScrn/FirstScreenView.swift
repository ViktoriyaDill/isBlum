//
//  FirstScreenView.swift
//  isBlum
//
//  Created by Пользователь on 12/02/2026.
//

import Foundation
import SwiftUI

// MARK: - Components for animations (Placeholders)

struct FirstStepCarouselView: View {
    let images = ["swipeCard", "swipeCard1", "swipeCard2", "swipeCard3"]
    
    @State private var scrollOffset: CGFloat = 0
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            let cardHeight = geo.size.height * 0.45
            let spacing: CGFloat = 12
            
            VStack {
                Spacer()
                VStack(spacing: spacing) {
                    ForEach(0..<images.count * 4, id: \.self) { index in
                        Image(images[index % images.count])
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geo.size.width * 0.6,
                                height: cardHeight
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                .offset(y: scrollOffset)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(timer) { _ in
                scrollOffset -= 0.8
                let threshold = CGFloat(images.count) * (cardHeight + spacing)
                if abs(scrollOffset) >= threshold {
                    scrollOffset = 0
                }
            }
        }
    }
}
