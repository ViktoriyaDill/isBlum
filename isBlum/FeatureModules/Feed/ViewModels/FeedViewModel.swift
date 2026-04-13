import Foundation
import Supabase

@MainActor
class FeedViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isShowingCachedData = false
    @Published var error: String?

    private let client = SupabaseService.shared.client

    func fetchProducts() async {
        guard !isLoading else { return }
        isLoading = products.isEmpty
        defer { isLoading = false }

        do {
            // Step 1: Fetch products with nested images
            var productList: [Product] = try await client
                .from("products")
                .select("id, seller_id, title, description, price, currency, is_available, rating, total_reviews, product_images(id, product_id, url, position)")
                .eq("is_available", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value

            // Step 2: Apply price filters
            let filters = FilterService.shared.load()
            productList = productList.filter {
                $0.price >= Double(filters.priceMin) && $0.price <= Double(filters.priceMax)
            }

            // Step 3: Fetch seller profiles and enrich
            let sellerIds = Array(Set(productList.map { $0.sellerId.uuidString }))
            if !sellerIds.isEmpty {
                struct SellerRow: Decodable {
                    let id: UUID
                    let shopName: String
                    let logoUrl: String?
                    let isVerified: Bool?
                    enum CodingKeys: String, CodingKey {
                        case id
                        case shopName = "shop_name"
                        case logoUrl = "logo_url"
                        case isVerified = "is_verified"
                    }
                }
                let sellers: [SellerRow] = try await client
                    .from("seller_profiles")
                    .select("id, shop_name, logo_url, is_verified")
                    .in("id", values: sellerIds)
                    .execute()
                    .value

                let sellerMap = Dictionary(uniqueKeysWithValues: sellers.map { ($0.id, $0) })
                productList = productList.map { product in
                    var p = product
                    if let seller = sellerMap[product.sellerId] {
                        p.sellerName = seller.shopName
                        p.sellerLogoUrl = seller.logoUrl
                        p.isSellerVerified = seller.isVerified ?? false
                    }
                    return p
                }
            }

            self.products = productList
            CacheService.save(productList, key: "feed_products")
            isShowingCachedData = false

        } catch {
            print("FeedViewModel fetchProducts error:", error)
            if let cached = CacheService.load([Product].self, key: "feed_products"), !cached.isEmpty {
                self.products = cached
                self.isShowingCachedData = true
            } else {
                self.error = error.localizedDescription
            }
        }
    }
}
