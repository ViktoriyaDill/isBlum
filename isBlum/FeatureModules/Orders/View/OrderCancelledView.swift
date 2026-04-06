//
//  OrderCancelledView.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 06/04/2026.
//

import SwiftUI

struct OrderCancelledView: View {

    /// Викликається після авто-дисмісу (через 2.5 с)
    let onDismiss: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                Color.white
                
                // MARK: Bottom blob background
                Image(.deleteBackground)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()

                // MARK: Centered content
                VStack(spacing: 20) {
                    Image(.flowers83)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    Text("order_cancelled_title")
                        .font(.onest(.bold, size: 32))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onDismiss()
            }
        }
    }
}

