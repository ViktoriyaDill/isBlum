//
//  SupabaseService.swift
//  isBlum
//
//  Created by Пользователь on 27/02/2026.
//

import Foundation
import Supabase
import Auth

class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://akbftxolqkvdmxqyrmao.supabase.co")!,
            supabaseKey: "sb_publishable_JqYh_JgtcOkPxPKQgkCcBA_-d_Ey3x5"
        )
    }
    
    func updateDeviceToken(userId: UUID, token: String) async {
            let updateData = ["device_token": token]
            
            do {
                try await client
                    .from("profiles")
                    .update(updateData)
                    .eq("id", value: userId.uuidString)
                    .execute()
                
                print("LOG: Device token successfully updated in Supabase for user \(userId)")
            } catch {
                print("ERROR: Failed to save device token: \(error.localizedDescription)")
            }
        }
}
