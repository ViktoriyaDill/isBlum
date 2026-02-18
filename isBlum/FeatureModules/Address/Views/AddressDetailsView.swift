//
//  AddressDetailsView.swift
//  isBlum
//
//  Created by Пользователь on 18/02/2026.
//

import SwiftUI
import MapKit

struct AddressDetailsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let selectedAddress: String
    
    // Form fields
    @State private var apartment = ""
    @State private var entrance = ""
    @State private var floor = ""
    @State private var intercom = ""
    
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var markerCoordinate: CLLocationCoordinate2D?

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Адреса доставки", showBackButton: true) {
                coordinator.goBack()
            }
            
            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 1. Mini Map Preview
                        Map(position: $cameraPosition) {
                            if let coordinate = markerCoordinate {
                                Annotation("", coordinate: coordinate) {
                                    Image(.homeMarker)
                                        .resizable()
                                        .frame(width: 46, height: 50)
                                }
                            }
                        }
                        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
                        .disabled(true)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(alignment: .bottom) {
                            Button(action: {
                                coordinator.goBack()
                            }) {
                                Text("Змінити точку")
                                    .font(.onest(.medium, size: 16))
                                    .foregroundStyle(Color.black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                            }
                            .padding(.bottom, 12)
                        }
                        
                        // 2. Address Display
                        HStack(alignment: .center, spacing: 12) {
                            Image(.geolocationPin)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Адреса доставки")
                                    .font(.onest(.medium, size: 12))
                                    .foregroundColor(Color(hex: "535852"))
                                Text(selectedAddress)
                                    .font(.onest(.regular, size: 16))
                            }
                            Spacer()
                        }
                        
                        // 3. Grid of details
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DetailInputField(label: "Квартира", text: $apartment)
                            DetailInputField(label: "Під'їзд", text: $entrance)
                            DetailInputField(label: "Поверх", text: $floor)
                            DetailInputField(label: "Домофон", text: $intercom)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
            }
        }
        .background(Color(.onboardBack).ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await geocodeAddress()
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                let details = AddressDetails(
                    streetAddress: selectedAddress,
                    apartment: apartment,
                    entrance: entrance,
                    floor: floor,
                    intercom: intercom
                )
                coordinator.completeAddressSetup(details: details)
            }) {
                Text("Зберегти адресу")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "9AF19A"))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
    
    private func geocodeAddress() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = selectedAddress
        
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            if let item = response.mapItems.first {
                let coordinate = item.placemark.coordinate
                self.markerCoordinate = coordinate
                self.cameraPosition = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                ))
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }
    }
}

// Helper View for small inputs
struct DetailInputField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(label, text: $text)
                .font(.onest(.regular, size: 16))
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryBorder, lineWidth: 1.5)
                )
        }
    }
}

#Preview {
    AddressDetailsView(selectedAddress: "Олександрівський проспект 43, Київ")
        .environmentObject(AppCoordinator())
}


