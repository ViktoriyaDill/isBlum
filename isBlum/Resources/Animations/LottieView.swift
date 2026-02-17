import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    @Binding var play: Bool
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.tag = 1001
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let animationView = uiView.viewWithTag(1001) as? LottieAnimationView {
            if play {
                if !animationView.isAnimationPlaying {
                    animationView.play()
                }
            } else {
                animationView.pause()
            }
        }
    }
}
