//
//  SuccessAuthView.swift
//  isBlum
//
//  Created by Пользователь on 01/03/2026.
//

import Foundation
import SwiftUI

struct SuccessAuthView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Image("success_bg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Image("leaf_illustration")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                
                VStack(spacing: 8) {
                    Text("Код прийнято!")
                        .font(.onest(.bold, size: 32))
                        .foregroundColor(.black)
                    
                    Text("Код введено вірно")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(.black.opacity(0.6))
                }
                Spacer()
            }
            .multilineTextAlignment(.center)
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .interactiveDismissDisabled(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    coordinator.profilePath = NavigationPath()
                    coordinator.appState = .main
                }
            }
        }
    }
}

#Preview {
    SuccessAuthView()
        .environmentObject(AppCoordinator())
}
