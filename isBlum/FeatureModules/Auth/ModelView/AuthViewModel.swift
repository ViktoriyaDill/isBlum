    //
    //  AuthViewModel.swift
    //  isBlum
    //
    //  Created by Пользователь on 24/02/2026.
    //

    import Foundation
    import UIKit
    import Supabase
    import GoogleSignIn
    import AuthenticationServices
    import CryptoKit

    @MainActor
    class AuthViewModel: ObservableObject {
        @Published var isLoading = false
        @Published var authError: String?
        @Published var isAuthenticated = false
        @Published var currentUser: UserProfile?
        @Published var justSignedIn = false
        
        private var currentNonce: String?
        
        weak var coordinator: AppCoordinator?
        
        private let client = SupabaseService.shared.client
        
        init() {
            Task {
                for await state in client.auth.authStateChanges {
                    switch state.event {
                    case .signedIn:
                        self.isAuthenticated = true
                        await self.fetchProfile()
                        await self.syncLocalAddressToDatabase()
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
        
        // MARK: - Native Google Sign-In (One Tap style)
        func signInWithGoogle() async {
            isLoading = true
            authError = nil

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                authError = "UI context error"
                isLoading = false
                return
            }

            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

                guard let idToken = result.user.idToken?.tokenString else {
                    throw NSError(domain: "Auth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to retrieve ID Token"
                    ])
                }

                let accessToken = result.user.accessToken.tokenString

                try await client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .google,
                        idToken: idToken,
                        accessToken: accessToken
                    )
                )

                await syncGoogleProfile(user: result.user)
                self.justSignedIn = true

            } catch {
                let nsError = error as NSError
                if nsError.domain == kGIDSignInErrorDomain,
                   nsError.code == GIDSignInError.canceled.rawValue {
                    print("User cancelled Google Sign-In")
                } else {
                    print("Google Sign-In error: \(error.localizedDescription)")
                    authError = "Google Sign-In failed: \(error.localizedDescription)"
                }
            }

            isLoading = false
        }


        // MARK: - Sync Google profile data
        private func syncGoogleProfile(user: GIDGoogleUser) async {
            guard let userId = client.auth.currentUser?.id else { return }
            
            let name = user.profile?.name ?? ""
            let avatarUrl = user.profile?.imageURL(withDimension: 200)?.absoluteString
            let email = user.profile?.email ?? ""
            
            do {
                try await client
                    .from("profiles")
                    .upsert([
                        "id": userId.uuidString,
                        "name": name,
                        "email": email,
                        "avatar_url": avatarUrl ?? ""
                    ], onConflict: "id")
                    .execute()
                
                await fetchProfile()
                
            } catch {
                print("Google profile sync error:", error)
            }
        }
        
        // MARK: - Native Apple Sign-In
        func signInWithApple() async {
            isLoading = true
            authError = nil
            
            let nonce = randomNonceString()
            currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            do {
                let authorization = try await performAppleSignIn(controller: authorizationController)
                
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                      let idTokenData = appleIDCredential.identityToken,
                      let idToken = String(data: idTokenData, encoding: .utf8) else {
                    throw NSError(domain: "Auth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to fetch ID Token from Apple"
                    ])
                }
                
                try await client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: idToken,
                        nonce: nonce
                    )
                )
                
                if let fullName = appleIDCredential.fullName {
                    let name = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    if !name.isEmpty {
                        await updateProfile(name: name, phone: nil)
                    }
                }
                
                self.justSignedIn = true
                
            } catch {
                let nsError = error as NSError
                if nsError.domain == ASAuthorizationError.errorDomain,
                   nsError.code == ASAuthorizationError.canceled.rawValue {
                    print("User cancelled Apple Sign-In")
                } else {
                    print("Apple Sign-In error: \(error.localizedDescription)")
                    authError = "Apple Sign-In failed"
                }
            }
            
            isLoading = false
        }

            // MARK: - Helper Methods for Apple Sign-In
            private func randomNonceString(length: Int = 32) -> String {
                var charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
                var result = ""
                var remainingLength = length
                while remainingLength > 0 {
                    let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
                    randoms.forEach { random in
                        if remainingLength == 0 { return }
                        if random < charset.count {
                            result.append(charset[Int(random)])
                            remainingLength -= 1
                        }
                    }
                }
                return result
            }

            private func sha256(_ input: String) -> String {
                let inputData = Data(input.utf8)
                let hashedData = SHA256.hash(data: inputData)
                let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
                return hashString
            }
        // MARK: - Email OTP
        func sendEmailOTP(email: String) async {
            isLoading = true
            authError = nil
            defer { isLoading = false }
            do {
                try await client.auth.signInWithOTP(email: email)
            } catch {
                print("Email OTP send error: \(error.localizedDescription)")
                handleError(error) {
                    Task { await self.sendEmailOTP(email: email) }
                }
            }
        }

        func verifyEmailOTP(email: String, token: String) async {
            isLoading = true
            authError = nil
            defer { isLoading = false }
            do {
                try await client.auth.verifyOTP(
                    email: email,
                    token: token,
                    type: .email
                )
            } catch {
                print("Email OTP verification error: \(error.localizedDescription)")
                authError = "Invalid code. Please try again."
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
                print("SMS OTP send error: \(error.localizedDescription)")
                handleError(error) {
                    Task { await self.sendOTP(phone: phone) }
                }
            }
        }
        
        func verifyOTP(phone: String, token: String) async {
            isLoading = true
            authError = nil
            defer { isLoading = false }
            do {
                try await client.auth.verifyOTP(
                    phone: phone,
                    token: token,
                    type: .sms
                )
            } catch {
                print("SMS OTP verification error: \(error.localizedDescription)")
                authError = "Invalid code. Please try again."
            }
        }
        
        // MARK: - Profile Management
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
                print("Profile fetch error:", error)
                handleError(error) {
                    Task { await self.fetchProfile() }
                }
            }
        }
        
        func updateProfile(name: String?, phone: String?) async {
            
            guard let userId = client.auth.currentUser?.id else { return }
            
            isLoading = true
            defer { isLoading = false }
            
            do {
                
                var updates: [String: String] = [:]
                
                if let name = name {
                    updates["name"] = name
                }
                
                if let phone = phone {
                    updates["phone"] = phone
                }
                
                try await client
                    .from("profiles")
                    .update(updates)
                    .eq("id", value: userId)
                    .execute()
                
                await fetchProfile()
                
            } catch {
                print("Profile update error:", error)
                handleError(error) {
                    Task { await self.updateProfile(name: name, phone: phone) }
                }
            }
        }
        
        func updateEmail(_ email: String) async {
            
            isLoading = true
            authError = nil
            defer { isLoading = false }
            
            do {
                
                try await client.auth.update(
                    user: UserAttributes(email: email)
                )
                
                authError = "Лист для підтвердження надіслано на нову пошту."
                
            } catch {
                
                authError = "Помилка оновлення: \(error.localizedDescription)"
            }
        }
        
        // MARK: - Session Management
        
        func handleAuthCallback(url: URL) async {
            do {
                try await client.auth.session(from: url)
            } catch {
                print("Auth callback error: \(error.localizedDescription)")
                authError = error.localizedDescription
            }
        }
        
        // Check verification status (from your DB or Supabase Auth metadata)
        var isPhoneUnverified: Bool {
            !(currentUser?.isPhoneVerified ?? false)
        }
        
        var isEmailUnverified: Bool {
            !(currentUser?.isEmailVerified ?? false)
        }
        
        func signOut() async {
            do {
                try await client.auth.signOut()
            } catch {
                print("Sign out error: \(error.localizedDescription)")
                authError = error.localizedDescription
            }
        }
        
        // MARK: - Account Deletion
        func deleteAccount(reason: String?) async {
            isLoading = true
            authError = nil
            defer { isLoading = false }
            
            do {
                if let reason = reason,
                   let userId = client.auth.currentUser?.id {
                    try await client
                        .from("account_deletion_reasons")
                        .insert([
                            "user_id": userId.uuidString,
                            "reason": reason
                        ])
                        .execute()
                }
                
                if let userId = client.auth.currentUser?.id {
                    try await client
                        .from("profiles")
                        .delete()
                        .eq("id", value: userId)
                        .execute()
                }
                
                try await client.rpc("delete_user").execute()
                
                FilterService.shared.reset()
                UserDefaults.standard.removeObject(forKey: "userAddress")
                UserDefaults.standard.removeObject(forKey: "hasSelectedFilters")
                
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                }
                
            } catch {
                print("Account deletion error: \(error.localizedDescription)")
                handleError(error) {
                    Task { await self.deleteAccount(reason: reason) }
                }
            }
        }
        
        // Helper to handle non-network errors
        private func handleError(_ error: Error, retry: @escaping () -> Void) {
            let message = error.localizedDescription.lowercased()
            let networkKeywords = ["network", "internet", "connection", "offline", "timed out"]
            let isNetworkError = networkKeywords.contains { message.contains($0) }
            
            if !isNetworkError {
                coordinator?.showError(retry: retry)
            }
        }
        
        // MARK: - Address Sync
        private func syncLocalAddressToDatabase() async {
            guard let details = LocationService.shared.loadFullAddress(),
                  let userId = client.auth.currentUser?.id else { return }
            
            do {
                // Check if user already has addresses in DB
                struct AddressID: Decodable { let id: UUID }
                let existing: [AddressID] = try await client
                    .from("addresses")
                    .select("id")
                    .eq("user_id", value: userId)
                    .limit(1)
                    .execute()
                    .value

                guard existing.isEmpty else { return }
                
                try await client
                    .from("addresses")
                    .insert([
                        "user_id": userId.uuidString,
                        "full_address": details.streetAddress,
                        "apartment": details.apartment,
                        "entrance": details.entrance,
                        "floor": details.floor,
                        "intercom": details.intercom,
                        "is_default": "true"
                    ])
                    .execute()
                
                print("Local address synced to database successfully")
                
            } catch {
                print("Address sync error:", error)
            }
        }
    }
