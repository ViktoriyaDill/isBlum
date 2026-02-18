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
    let onSelect: (AddressModel) -> Void
    @State private var selectedID: UUID?

    var body: some View {
        VStack(spacing: 4) {
            ForEach(results) { result in
                AddressResultRow(
                    address: result,
                    isSelected: selectedID == result.id
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedID = result.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        onSelect(result)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onAppear {
            selectedID = results.first?.id
        }
        .onChange(of: results) { newResults in
            selectedID = newResults.first?.id
        }
    }
}
