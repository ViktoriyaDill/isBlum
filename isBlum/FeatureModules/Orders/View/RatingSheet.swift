//
//  RatingSheet.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 23/03/2026.
//

import Foundation
import SwiftUI
import PhotosUI
import Storage

enum RatingStatus {
    case idle, loading, success, error
}

struct RatingSheet: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: AppCoordinator
    
    let order: Order
    let imageURL: URL?
    
    @Binding var currentStep: RatingStep
    
    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var selectedTags: Set<String> = []
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var attachedImageData: Data?
    @State private var attachedImageURL: String?
    @State private var isUploadingPhoto = false
    
    @State private var submissionState: RatingStatus = .idle
    
    private let client = SupabaseService.shared.client
    
    let tags: [String] = [
        "rating_tag_fast_delivery",
        "rating_tag_differs_from_photo",
        "rating_tag_as_in_photo",
        "rating_tag_neat_bouquet",
        "rating_tag_delivery_delay",
        "rating_tag_fresh_flowers",
        "rating_tag_wilted_fast",
        "rating_tag_damaged_packaging"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            headerView
            
            VStack(spacing: 24) {
                
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image(.appLogo)
                            .resizable()
                            .scaledToFill()
                            .padding(8)
                            .background(Color(hex: "F2F2F2"))
                    @unknown default:
                        Color(hex: "F2F2F2")
                    }
                }
                .frame(width: 96, height: 96)
                .cornerRadius(12)
                .clipped()
                
                
                switch currentStep {
                case .stars:
                    starsStep
                case .tags:
                    tagsStep
                case .comment, .commentWithPhoto:
                    commentStep
                }
                
                
                if currentStep != .stars {
                    mainButton
                }
            }
            .padding(24)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            if currentStep != .stars {
                Button(action: { goBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color(hex: "#F4F4F4"))
                        .clipShape(Circle())
                }
            } else {
                Button("rating_later_button") { dismiss() }
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(Color(hex: "#070A07"))
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color(hex: "#F4F4F4"))
                    .clipShape(Circle())
            }
        }
        .padding([.horizontal, .top], 16)
    }
    
    private var starsStep: some View {
        VStack(spacing: 16) {
            Text("rating_stars_title \(order.shopName)")
                .font(.onest(.bold, size: 24))
                .multilineTextAlignment(.center)
            
            Text("rating_stars_subtitle")
                .font(.onest(.regular, size: 16))
                .foregroundColor(Color(hex: "#535852"))
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: 32))
                        .foregroundColor(index <= rating ? Color(hex: "#F2C94C") : .gray.opacity(0.3))
                        .onTapGesture {
                            rating = index
                            withAnimation { currentStep = .tags }
                        }
                }
            }
            .padding(.top, 10)
        }
    }
    
    private var tagsStep: some View {
        VStack(spacing: 0) {
            Text("rating_tags_title")
                .font(.onest(.bold, size: 24))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("rating_tags_subtitle")
                .font(.onest(.regular, size: 16))
                .foregroundColor(Color(hex: "#535852"))
            
            // Гнучка сітка тегів
            FlowLayout(items: tags) { tag in
                TagView(
                    title: LocalizedStringKey(tag),
                    isSelected: selectedTags.contains(tag)
                ) {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                }
            }
        }
    }
    
    private var commentStep: some View {
        VStack(spacing: 16) {
            Text("rating_comment_title")
                .font(.onest(.bold, size: 20))
            
            TextEditor(text: $comment)
                .frame(height: 160)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2))
                )
                .overlay(alignment: .topLeading) {
                    if comment.isEmpty {
                        Text("rating_comment_placeholder")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .allowsHitTesting(false)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    if let imageData = attachedImageData,
                       let uiImage = UIImage(data: imageData) {
                        HStack(alignment: .bottom) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                                .clipped()
                                .overlay(alignment: .topTrailing) {
                                    Button(action: {
                                        attachedImageData = nil
                                        attachedImageURL = nil
                                        selectedPhotoItem = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .background(Color.white.clipShape(Circle()))
                                    }
                                    .offset(x: 5, y: -5)
                                }

                            if isUploadingPhoto {
                                ProgressView()
                            }
                        }
                        .padding(12)
                    } else {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "camera")
                                Text("rating_attach_photo")
                            }
                            .font(.onest(.medium, size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(hex: "F4F4F4"))
                            .cornerRadius(10)
                        }
                        .padding(12)
                    }
                }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task { await loadAndUploadPhoto(newItem) }
        }
    }
    
    private var mainButton: some View {
        Button(action: { handleNextAction() }) {
            Text(currentStep == .tags ? "rating_continue_button" : "rating_submit_button")
                .font(.onest(.medium, size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(hex: "#B8EEA6"))
                .cornerRadius(28)
        }
    }
    
    // MARK: - Logic
    
    private func handleNextAction() {
        if currentStep == .tags {
            withAnimation { currentStep = .comment }
        } else {
            Task { await submitReview() }
        }
    }
    
    private func submitReview() async {
        guard let userId = client.auth.currentUser?.id,
              let productId = order.items.first?.productId,
              rating > 0 else { return }
        
        await MainActor.run { submissionState = .loading }
        
        do {
            let localizedTags = selectedTags.map { key in
                String(localized: LocalizedStringResource(stringLiteral: key))
            }
            
            var images: [String] = []
            if let url = attachedImageURL {
                images.append(url)
            }
            
            struct ReviewInsert: Encodable {
                let order_id: UUID
                let product_id: UUID
                let seller_id: UUID
                let client_id: UUID
                let rating: Int
                let comment: String?
                let tags: [String]
                let images: [String]
            }
            
            let review = ReviewInsert(
                order_id: order.id,
                product_id: productId,
                seller_id: order.sellerId,
                client_id: userId,
                rating: rating,
                comment: comment.isEmpty ? nil : comment,
                tags: localizedTags,
                images: images
            )
            
            try await client
                .from("reviews")
                .insert(review)
                .execute()
            
            await MainActor.run { submissionState = .success }
            
            try? await Task.sleep(nanoseconds: 800_000_000)
            
            await MainActor.run {
                dismiss()
                coordinator.ordersPath.append(AppRoute.successRating)
            }
            
        } catch {
            print("Submit review error:", error)
            await MainActor.run {
                withAnimation(.spring()) {
                    submissionState = .error
                }
            }
        }
    }
    
    private func goBack() {
        withAnimation {
            if currentStep == .comment || currentStep == .commentWithPhoto {
                currentStep = .tags
            } else if currentStep == .tags {
                currentStep = .stars
            }
        }
    }
    
    private func loadAndUploadPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isUploadingPhoto = true
        defer { isUploadingPhoto = false }
        
        do {
            // 1. Отримати Data з PhotosPickerItem
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            
            // Стискаємо фото щоб не перевантажувати Storage
            guard let uiImage = UIImage(data: data),
                  let compressedData = uiImage.jpegData(compressionQuality: 0.7) else { return }
            
            await MainActor.run {
                attachedImageData = compressedData
            }
            
            // 2. Генеруємо унікальне ім'я файлу
            let fileName = "\(order.id.uuidString)/\(UUID().uuidString).jpg"
            
            // 3. Завантажуємо в Supabase Storage
            try await client.storage
                .from("review-photos")
                .upload(
                    fileName,
                    data: compressedData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // 4. Отримуємо публічний URL
            let publicURL = try client.storage
                .from("review-photos")
                .getPublicURL(path: fileName)
            
            await MainActor.run {
                attachedImageURL = publicURL.absoluteString
            }
            
            print("Photo uploaded: \(publicURL)")
            
        } catch {
            print("Photo upload error:", error)
            await MainActor.run {
                attachedImageData = nil
                selectedPhotoItem = nil
            }
        }
    }
    
}
