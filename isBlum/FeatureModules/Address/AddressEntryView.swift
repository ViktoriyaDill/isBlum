import SwiftUI

struct AddressEntryView: View {
    @StateObject private var viewModel = AddressViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Адреса доставки", showBackButton: false) {
                coordinator.goBack()
            }
            
            ZStack(alignment: .top) {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Text("Введіть адресу\nдоставки")
                            .font(.onest(.bold, size: 32))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            AddressInputField(text: $viewModel.searchText, placeholder: "Адреса доставки") {
                                viewModel.searchText = ""
                            }
                            .submitLabel(.done)
                            .onSubmit {
                                if let first = viewModel.results.first {
                                    viewModel.selectAddress(first)
                                }
                            }
                            
                            // Current location button shows only when search is empty
                            if viewModel.searchText.isEmpty {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        viewModel.requestLocation()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(.currentLocation)
                                            .font(.system(size: 14))
                                        Text("Визначити місцезнаходження")
                                            .font(.onest(.medium, size: 14))
                                    }
                                    .foregroundColor(.black)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            // Results list
                            if !viewModel.searchText.isEmpty {
                                if viewModel.results.isEmpty {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .padding()
                                        Spacer()
                                    }
                                } else {
                                    AddressResultsList(results: viewModel.results) { selected in
                                        viewModel.selectAddress(selected)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        // Logic to clear field on entry and return
        .task {
            viewModel.clearSearch()
        }
        .background(Color(.onboardBack).ignoresSafeArea())
        .navigationBarHidden(true)
        
        .safeAreaInset(edge: .bottom) {
            if !viewModel.results.isEmpty {
                MapSelectionButton {
                    coordinator.showMapSelection()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color.white)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.results.isEmpty)
        // Ensure animation triggers when text is cleared
        .animation(.easeInOut, value: viewModel.searchText.isEmpty)
    }
}
