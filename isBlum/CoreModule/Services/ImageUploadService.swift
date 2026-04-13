import UIKit
import Supabase

enum ImageUploadService {

    /// Compresses and uploads a UIImage to Supabase Storage.
    /// - Parameters:
    ///   - image: The image to upload.
    ///   - bucket: Storage bucket name (e.g. "chat-images", "review-photos").
    ///   - folder: Path prefix inside the bucket (e.g. chatId or orderId string).
    ///   - quality: JPEG compression quality (0.0–1.0). Defaults to 0.8.
    /// - Returns: Public URL string of the uploaded file.
    static func upload(
        _ image: UIImage,
        bucket: String,
        folder: String,
        quality: CGFloat = 0.8
    ) async throws -> String {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw UploadError.compressionFailed
        }

        let client = SupabaseService.shared.client
        let fileName = "\(folder)/\(UUID().uuidString).jpg"

        try await client.storage
            .from(bucket)
            .upload(fileName, data: data, options: FileOptions(contentType: "image/jpeg"))

        let publicURL = try client.storage
            .from(bucket)
            .getPublicURL(path: fileName)

        return publicURL.absoluteString
    }

    enum UploadError: Error {
        case compressionFailed
    }
}
