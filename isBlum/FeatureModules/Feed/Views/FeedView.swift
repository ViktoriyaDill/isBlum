import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @AppStorage("hasSeenFeedOnboarding") private var hasSeenOnboarding = false
    @EnvironmentObject var coordinator: AppCoordinator

    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showAddressPicker = false

    private var totalPages: Int { viewModel.products.count + 1 }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            Color.white .ignoresSafeArea()

            // Main layout: top bar → cards area → tab bar reservation
            VStack(spacing: 0) {
                topBar
                    .zIndex(1)

                GeometryReader { cardGeo in
                    ZStack {
                        if viewModel.isLoading && viewModel.products.isEmpty {
                            FeedSkeletonView()
                        } else if viewModel.products.isEmpty {
                            filterEmptyState
                        } else {
                            feedCardsView(geo: cardGeo)
                        }
                    }
                    .frame(width: cardGeo.size.width, height: cardGeo.size.height)
                }

                // Reserve space for tab bar + home indicator
                Color.clear.frame(height: tabBarReservation)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Offline banner — below top bar
            if viewModel.isShowingCachedData {
                offlineBanner
                    .padding(.top, topBarTotalHeight)
                    .zIndex(2)
            }

            // Onboarding — full-screen overlay
            if !hasSeenOnboarding {
                FeedOnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasSeenOnboarding = true
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .ignoresSafeArea()
        .task { await viewModel.fetchProducts() }
        .sheet(isPresented: $showAddressPicker) {
            FeedAddressPickerSheet(isPresented: $showAddressPicker)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }

    // MARK: - Feed Cards

    @ViewBuilder
    private func feedCardsView(geo: GeometryProxy) -> some View {
        let h = geo.size.height
        let w = geo.size.width
        let products = viewModel.products

        ZStack {
            ForEach(visibleIndices(total: totalPages), id: \.self) { index in
                Group {
                    if index < products.count {
                        FeedCardView(product: products[index])
                    } else {
                        endOfFeedCard
                    }
                }
                .frame(width: w, height: h)
                .offset(y: CGFloat(index - currentIndex) * h + dragOffset)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: currentIndex)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: dragOffset)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard abs(value.translation.height) > abs(value.translation.width) else { return }
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    let dy = value.translation.height
                    let dx = value.translation.width
                    guard abs(dy) > abs(dx) else {
                        withAnimation { dragOffset = 0 }
                        return
                    }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        if dy < -60 && currentIndex < totalPages - 1 {
                            currentIndex += 1
                        } else if dy > 60 && currentIndex > 0 {
                            currentIndex -= 1
                        }
                        dragOffset = 0
                    }
                }
        )
    }

    private func visibleIndices(total: Int) -> [Int] {
        var result: [Int] = []
        if currentIndex > 0 { result.append(currentIndex - 1) }
        result.append(currentIndex)
        if currentIndex < total - 1 { result.append(currentIndex + 1) }
        return result
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 0) {
            // Status bar spacer (inside background so blur covers it too)
            Color.white.frame(height: topSafeAreaHeight)

            HStack(alignment: .center) {
                Button { showAddressPicker = true } label: {
                    HStack(spacing: 10) {
                        Image(.mappin)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "9AF19A"))
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Доставка • Сьогодні")
                                .font(.onest(.medium, size: 12))
                                .foregroundColor(.gray)
                            HStack(spacing: 4){
                                Text(userAddress)
                                    .font(.onest(.medium, size: 12))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button { /* TODO: filters */ } label: {
                    Image(.sliderFilters)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(.white)
    }

    // MARK: - End of Feed Card

    private var endOfFeedCard: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "#F4F4F4")).cornerRadius(28)

            VStack(spacing: 0) {
                Spacer()

                Image(.buquetsEmptyIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 28)

                VStack(spacing: 8){
                    Text("Букети закінчилися")
                        .font(.onest(.bold, size: 24))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("Ви переглянули всі доступні букети.\nФлористи оновлюють добірки протягом дня")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        currentIndex = 0
                    }
                } label: {
                    Text("Почати спочатку")
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "B8EEA6"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                Button { /* TODO: filters */ } label: {
                    Text("Змінити фільтри")
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }

    // MARK: - Filter Empty State

    private var filterEmptyState: some View {
        ZStack {
            Color(hex: "F7F7F7")

            VStack(spacing: 0) {
                Spacer()

                Image(.ordersEmptyIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 28)

                Text("Букетів за цими фільтрами\nпоки немає")
                    .font(.onest(.bold, size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                Text("Спробуйте змінити фільтри")
                    .font(.onest(.regular, size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)

                Button { /* TODO: filters */ } label: {
                    Text("Змінити фільтри")
                        .font(.onest(.semiBold, size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "B8EEA6"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    // MARK: - Offline Banner

    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 13, weight: .medium))
            Text("Показано збережені дані")
                .font(.onest(.medium, size: 13))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.8))
    }

    // MARK: - Helpers

    private var topSafeAreaHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44
    }

    private var bottomSafeAreaHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }

    /// Tab bar (70pt) + home indicator
    private var tabBarReservation: CGFloat { 70 + bottomSafeAreaHeight }

    /// Total height of the top bar (status bar + content row) for overlay positioning
    private var topBarTotalHeight: CGFloat { topSafeAreaHeight + 44 + 24 }

    private var userAddress: String {
        UserDefaults.standard.string(forKey: "userAddress") ?? "Ваше місто"
    }
}
