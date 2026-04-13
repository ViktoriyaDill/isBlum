import SwiftUI

struct FeedCardView: View {
    let product: Product

    @State private var currentImageIndex = 0

    private var images: [ProductImage] { product.sortedImages }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // MARK: - Image Carousel
                if images.isEmpty {
                    Rectangle()
                        .fill(Color(hex: "#F4F4F4"))
                        .cornerRadius(28)
                } else {
                    TabView(selection: $currentImageIndex) {
                        ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                            AsyncImage(url: URL(string: image.url)) { phase in
                                switch phase {
                                case .success(let img):
                                    img
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Rectangle().fill(Color(hex: "#F4F4F4")).cornerRadius(28)
                                case .empty:
                                    Rectangle().fill(Color(hex: "#F4F4F4")).cornerRadius(28)
                                @unknown default:
                                    Rectangle().fill(Color(hex: "#F4F4F4")).cornerRadius(28)
                                }
                            }
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(width: geo.size.width, height: geo.size.height)
                }

                // MARK: - Top Badges
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        badgePill(
                            icon: "location",
                            iconColor: Color(hex: "#535852"),
                            text: "2 км від вас",
                            backgroundColor: Color(hex: "#FFFFFF")
                        )
                        badgePill(
                            icon: "freeDelivery",
                            iconColor: Color(hex: "#5B4D14"),
                            text: "Безкоштовна доставка",
                            backgroundColor: Color(hex: "#FAF2D6")
                        )
                        
                        Spacer()
                    }
                        badgePill(
                            icon: "time",
                            iconColor: Color(hex: "#094109"),
                            text: "Доставимо за 30 хвилин",
                            backgroundColor: Color(hex: "#F1FDF0")
                        )
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, geo.safeAreaInsets.top + 24)

                // MARK: - Bottom Content
                VStack(spacing: 0) {
                    HStack(alignment: .bottom) {
                        // Left: title + price
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.title)
                                .font(.onest(.bold, size: 22))
                                .foregroundColor(.white)
                                .lineLimit(2)

                            Text(product.formattedPrice)
                                .font(.onest(.regular, size: 16))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // Right: seller avatar + view button badge
                        ZStack(alignment: .bottomTrailing) {
                            // Seller avatar
                            Image(.messageShopLogo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())

                            Button {
                                print("FeedCardView: view product \(product.id)")
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "9AF19A"))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                            .offset(x: 4, y: 4)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private var sellerInitialView: some View {
        let initial = product.sellerName.first.map(String.init) ?? "?"
        let colors: [Color] = [
            Color(hex: "B8EEA6"),
            Color(hex: "9AF19A"),
            Color(hex: "D4F0FF"),
            Color(hex: "FFD4E8")
        ]
        let colorIndex = abs(product.sellerName.hashValue) % colors.count
        return ZStack {
            colors[colorIndex]
            Text(initial)
                .font(.onest(.bold, size: 18))
                .foregroundColor(.white)
        }
        .eraseToAnyView()
    }

    private func badgePill(icon: String, iconColor: Color, text: String, backgroundColor: Color) -> some View {
        HStack(spacing: 4) {
            Image(icon)
                .font(.system(size: 12))
                .foregroundColor(iconColor)
            Text(text)
                .font(.onest(.medium, size: 12))
                .foregroundColor(iconColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - AnyView Helper

private extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
