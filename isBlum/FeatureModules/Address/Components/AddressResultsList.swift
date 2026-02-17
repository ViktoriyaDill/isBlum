//
//  AddressResultsList.swift
//  isBlum
//
//  Created by Пользователь on 13/02/2026.
//

import Foundation
import SwiftUI

struct AddressResultsList: View {
    let results: [AddressModel]
    @State private var selectedID: UUID? = nil
    let onSelect: (AddressModel) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(results.indices, id: \.self) { index in
                let result = results[index]
                AddressResultRow(
                    address: result,
                    isSelected: selectedID == result.id || (selectedID == nil && index == 0)
                )
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
