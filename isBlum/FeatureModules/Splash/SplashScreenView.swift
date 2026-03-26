import SwiftUI

struct SplashScreenView: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.splashBrand200)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(.appLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                ShimmeringLogo()
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.3, dampingFraction: 0.7, blendDuration: 0)) {
                isAnimating = true
            }
        }
    }
}


#Preview {
    SplashScreenView()
}
