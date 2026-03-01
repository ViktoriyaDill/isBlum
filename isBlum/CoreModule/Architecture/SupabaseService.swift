//
//  SupabaseService.swift
//  isBlum
//
//  Created by Пользователь on 27/02/2026.
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    let client = SupabaseClient(
      supabaseURL: URL(string: "https://akbftxolqkvdmxqyrmao.supabase.co")!,
      supabaseKey: "sb_publishable_JqYh_JgtcOkPxPKQgkCcBA_-d_Ey3x5"
    )
    
    private init() {}
}
