//
//  OnboardingView.swift
//  isBlum
//
//  Created by Пользователь on 09/02/2026.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentStep = 0
    
    var body: some View {
        VStack {
//            TabView(selection: $currentStep) {
//                // Слайд 1
//                OnboardingStepView(title: "Обирай найкраще", image: "flowers_1")
//                    .tag(0)
//                
//                // Слайд 2
//                OnboardingStepView(title: "Поруч з тобою", image: "map_location")
//                    .tag(1)
//                
//                // Слайд 3
//                OnboardingStepView(title: "Швидка доставка", image: "delivery_truck")
//                    .tag(2)
//            }
//            .tabViewStyle(.page(indexDisplayMode: .always))
            
            // Кнопка дії
            Button(action: {
                if currentStep < 2 {
                    withAnimation { currentStep += 1 }
                } else {
                    hasSeenOnboarding = true // Закриваємо онбординг назавжди
                }
            }) {
                Text(currentStep == 2 ? "Почати" : "Далі")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue) // Твій колір з дизайну
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
    }
}
