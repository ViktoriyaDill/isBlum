

import SwiftUI



struct AddressEntryView: View {
    @StateObject private var viewModel = AddressViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // Вимикаємо кнопку Back для найпершого екрана
            CustomNavigationBar(title: "Адреса доставки", showBackButton: false) {
                coordinator.goBack()
            }
            
            ZStack(alignment: .top) {
                // Біла підкладка з заокругленням
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
                            // Поле вводу з підтримкою Enter
                            AddressInputField(text: $viewModel.searchText, placeholder: "Адреса доставки") {
                                viewModel.searchText = ""
                            }
                            .submitLabel(.done)
                            .onSubmit {
                                // Підтвердження вибору через Enter
                                if let first = viewModel.results.first {
                                    viewModel.selectAddress(first)
                                }
                            }
                            
                            // Кнопка локації зникає, якщо поле не порожнє
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
                            
                            // Список результатів
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
                                        // Тут можна додати перехід: coordinator.push(.addressDetails)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    // Відступ знизу, щоб контент не перекривався кнопкою "Вказати на карті"
                    .padding(.bottom, 120)
                }
            }
        }
        .background(Color(.onboardBack).ignoresSafeArea())
        .navigationBarHidden(true)
        // Фіксована кнопка внизу екрана
        .overlay(alignment: .bottom) {
            MapSelectionButton {
                /* Перехід на карту */
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .animation(.easeInOut, value: viewModel.searchText.isEmpty)
    }
}

#Preview {
    AddressEntryView()
        .environmentObject(AppCoordinator())
}
