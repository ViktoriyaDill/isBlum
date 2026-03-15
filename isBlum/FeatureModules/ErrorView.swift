//
//  ErrorView.swift
//  isBlum
//
//  Created by Пользователь on 15/03/2026.
//

import Foundation
import SwiftUI


enum ErrorViewType {
    case noInternet
    case general
    
    var icon: ImageResource {
        switch self {
        case .noInternet: return .noInternetIcon
        case .general: return .starErrorIcon
        }
    }
    
    var title: LocalizedStringResource {
        switch self {
        case .noInternet: return "error_no_internet_title"
        case .general: return "error_general_title"
        }
    }
    
    var description: LocalizedStringResource {
        switch self {
        case .noInternet: return "error_no_internet_description"
        case .general: return "error_general_description"
        }
    }
}

struct ErrorView: View {
    
    let type: ErrorViewType
    var retryAction: () -> Void
    
    var body: some View {
        ZStack {
            Image(.deleteBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                Image(type.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .padding(.bottom, 24)
                
                Text(type.title)
                    .font(.onest(.bold, size: 32))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 16)
                
                Text(type.description)
                    .font(.onest(.regular, size: 16))
                    .foregroundColor(Color(hex: "#535852"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: {
                    retryAction()
                }) {
                    Text("error_retry_connection")
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#9AF19A"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
    }
}

// MARK: - Preview
#Preview("General Error") {
    ErrorView(type: .general, retryAction: {
        print("Retry tapped")
    })
}

//#Preview("No Internet") {
//    ErrorView(type: .noInternet, retryAction: {
//        print("Retry tapped")
//    })
//}
