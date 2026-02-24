//
//  AuthViewModel.swift
//  isBlum
//
//  Created by Пользователь on 24/02/2026.
//

import Foundation
//import Supabase

@MainActor
class AuthViewModel: ObservableObject {
//    @Published var isLoading = false
//    @Published var authError: String?
//    
//    private let client = SupabaseService.shared.client
//    
//    // Auth with Email and Password
//    func signInWithEmail(email: String) async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            // Supabase sends a Magic Link or uses password depending on your setup
//            try await client.auth.signInWithOtp(email: email)
//            print("Magic link sent to \(email)")
//        } catch {
//            authError = error.localizedDescription
//        }
//    }
//    
//    // Auth with Google (OAuth)
//    func signInWithGoogle() async {
//        do {
//            let response = try await client.auth.getOAuthSignInURL(provider: .google)
//            // Handle opening the URL in a browser or ASWebAuthenticationSession
//            if let url = response.url {
//                await UIApplication.shared.open(url)
//            }
//        } catch {
//            authError = error.localizedDescription
//        }
//    }
}
