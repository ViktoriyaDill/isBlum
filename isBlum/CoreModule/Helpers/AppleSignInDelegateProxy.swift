import Foundation
import AuthenticationServices
import UIKit

class AppleSignInDelegateProxy: NSObject,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    private let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation.resume(throwing: error)
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return UIWindow()
        }
        return window
    }
}

func performAppleSignIn(controller: ASAuthorizationController) async throws -> ASAuthorization {
    try await withCheckedThrowingContinuation { continuation in
        let proxy = AppleSignInDelegateProxy(continuation: continuation)
        controller.delegate = proxy
        controller.presentationContextProvider = proxy 
        objc_setAssociatedObject(controller, "delegateProxy", proxy, .OBJC_ASSOCIATION_RETAIN)
        controller.performRequests()
    }
}
