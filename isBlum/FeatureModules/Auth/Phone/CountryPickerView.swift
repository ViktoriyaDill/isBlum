//
//  CountryPickerView.swift
//  isBlum
//
//  Created by Пользователь on 01/03/2026.
//

import Foundation
import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCountry: Country
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty { return countries }
        return countries.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with Close Button
            HStack {
                Spacer()
                Text("Оберіть код країни")
                    .font(.onest(.bold, size: 22))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.2))
                        .font(.system(size: 30))
                }
            }
            .padding([.horizontal, .top], 20)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Пошук країни", text: $searchText)
                    .font(.onest(.regular, size: 16))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            .padding(.horizontal)
            
            // List of Countries
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredCountries) { country in
                        Button(action: {
                            selectedCountry = country
                            dismiss()
                        }) {
                            HStack {
                                Text(country.flag)
                                Text("\(country.name) (\(country.code))")
                                    .font(.onest(.regular, size: 16))
                                Spacer()
                                
                                // Selection indicator
                                ZStack {
                                    Circle()
                                        .stroke(selectedCountry == country ? Color(hex: "B5F1A0") : Color.gray.opacity(0.3), lineWidth: 1)
                                        .frame(width: 24, height: 24)
                                    
                                    if selectedCountry == country {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(hex: "B5F1A0"))
                                            .font(.system(size: 24))
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedCountry == country ? Color(hex: "B5F1A0").opacity(0.1) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCountry == country ? Color(hex: "B5F1A0") : Color.clear, lineWidth: 1)
                                    )
                            )
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        
                        Divider().padding(.horizontal)
                    }
                }
            }
        }
    }
}
