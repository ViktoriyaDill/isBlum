//
//  AuthViewModel.swift
//  isBlum
//
//  Created by Пользователь on 24/02/2026.
//

import Foundation
import UIKit
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var authError: String?
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    
    private let client = SupabaseService.shared.client
    
    init() {
        Task {
            for await state in client.auth.authStateChanges {
                switch state.event {
                case .signedIn:
                    self.isAuthenticated = true
                    await self.fetchProfile()
                case .signedOut:
                    self.isAuthenticated = false
                    self.currentUser = nil
                case .userUpdated:
                    await self.fetchProfile()
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Phone SMS OTP
    func sendOTP(phone: String) async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        do {
            try await client.auth.signInWithOTP(phone: phone)
        } catch {
            authError = "Не вдалось надіслати код. Перевірте номер телефону."
        }
    }
    
    func verifyOTP(phone: String, code: String) async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        do {
            try await client.auth.verifyOTP(
                phone: phone,
                token: code,
                type: .sms
            )
        } catch {
            authError = "Невірний код. Спробуйте ще раз."
        }
    }
    
    // MARK: - Google OAuth
    func signInWithGoogle() async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        do {
            let url = try client.auth.getOAuthSignInURL(
                provider: .google,
                redirectTo: URL(string: "isblum://auth/callback")
            )
            await UIApplication.shared.open(url)
        } catch {
            authError = error.localizedDescription
        }
    }
    
    // MARK: - Apple OAuth
    func signInWithApple() async {
        isLoading = true
        authError = nil
        defer { isLoading = false }
        do {
            let url = try client.auth.getOAuthSignInURL(
                provider: .apple,
                redirectTo: URL(string: "isblum://auth/callback")
            )
            await UIApplication.shared.open(url)
        } catch {
            authError = error.localizedDescription
        }
    }
    
    // MARK: - Callback
    func handleAuthCallback(url: URL) async {
        do {
            try await client.auth.session(from: url)
        } catch {
            authError = error.localizedDescription
        }
    }
    
    // MARK: - Profile
    func fetchProfile() async {
        guard let userId = client.auth.currentUser?.id else { return }
        do {
            let profile: UserProfile = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            self.currentUser = profile
        } catch {
            print("Profile fetch error: \(error)")
        }
    }
    
    func updateProfile(name: String?, phone: String?) async {
        guard let userId = client.auth.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            var updates: [String: AnyJSON] = [:]
            if let name { updates["name"] = .string(name) }
            if let phone { updates["phone"] = .string(phone) }
            
            try await client
                .from("profiles")
                .update(updates)
                .eq("id", value: userId)
                .execute()
            
            await fetchProfile()
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            authError = error.localizedDescription
        }
    }
    
    func verifyOTP(phone: String, token: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client.auth.verifyOTP(
                phone: phone,
                token: token,
                type: .sms // або .signup залежно від логіки
            )
        } catch {
            authError = error.localizedDescription
        }
    }
}
