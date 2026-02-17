//
//  MapSelectionView.swift
//  isBlum
//
//  Created by User on 17/02/2026.
//

import SwiftUI
import MapKit

struct MapSelectionView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = MapSelectionViewModel()
    
    var body: some View {
        ZStack {
            // 1. Map (iOS 17+ style)
            Map(position: $viewModel.cameraPosition, interactionModes: .all) {
                UserAnnotation()
            }
            .ignoresSafeArea()
            .onMapCameraChange(frequency: .continuous) { context in
                viewModel.setMapMoving(true)
                viewModel.centerCoordinate = context.region.center
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.setMapMoving(false)
                viewModel.centerCoordinate = context.region.center
            }

            // 2. Fixed Central Marker (SwiftUI Native Animation)
            VStack(spacing: 0) {
                ZStack {
                    // Dynamic shadow below the pin
                    Ellipse()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: viewModel.isMapMoving ? 12 : (viewModel.isIdleBouncing ? 18 : 24),
                               height: 6)
                        .blur(radius: viewModel.isMapMoving ? 2 : 0)
                        .offset(y: 4) // Position shadow at the very tip of the pin
                    
                    Image(.homeMarker)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 80)
                        // Lift height logic: -65 (moving), -48 (idle bounce peak), -40 (rest)
                        .offset(y: viewModel.isMapMoving ? -65 : (viewModel.isIdleBouncing ? -48 : -40))
                }
            }
            .allowsHitTesting(false)
            .animation(
                viewModel.isMapMoving
                    ? .spring(response: 0.35, dampingFraction: 0.6)
                    : .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: viewModel.isMapMoving || viewModel.isIdleBouncing
            )
            
            // 3. Back Button
            VStack {
                HStack {
                    Button(action: { coordinator.goBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                Spacer()
            }
            
            // 4. Bottom Section: GPS Button + Address Card
            VStack(spacing: 16) {
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.centerOnUser()
                    }) {
                        Image(.location)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Address Card
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8){
                        Text("Перемістіть маркер на точне місце доставки")
                            .font(.onest(.medium, size: 12))
                            .foregroundColor(Color(hex: "0C570C"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: "F1FDF0"))
                        
                        // Address Text
                        HStack(spacing: 12) {
                            Image(.geolocationPin)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text(viewModel.selectedAddress)
                                .font(.onest(.regular, size: 16))
                                .lineLimit(2)
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        .padding(.horizontal, 12)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "F4F4F4"), lineWidth: 1.5)
                    )
                    
                    // Confirm Button
                    Button(action: {
                        coordinator.finishLocationSelection(address: viewModel.selectedAddress)
                    }) {
                        Text("Доставити сюди")
                            .font(.onest(.medium, size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "9AF19A"))
                            .cornerRadius(28)
                    }
                }
                .padding(20)
                .padding(.bottom, 26)
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MapSelectionView().environmentObject(AppCoordinator())
}
