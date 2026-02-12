//
//  MapView.swift
//  isBlum
//
//  Created by Пользователь on 12/02/2026.
//

import Foundation
import SwiftUI
import Lottie

// MARK: - Lottie View Wrapper
struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: -  ThirdStepMapView

struct ThirdStepMapView: View {
    var body: some View {
        ZStack {
            Image("mapOnboard")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                
                MapMarkerHome()
                    .position(x: width * 0.25, y: height * 0.58)
                MapMarkerLogo()
                    .position(x: width * 0.78, y: height * 0.42)
            }
        }
    }
}

struct MapMarkerHome: View {
    var body: some View {
        ZStack {
            LottieView(name: "pulseAnimation")
                .frame(width: 100, height: 100)
            
            Image(.radiusIconHome)
                .resizable()
                .frame(width: 40, height: 40)
        }
    }
}

struct MapMarkerLogo: View {
    var body: some View {
        ZStack {
            LottieView(name: "pulseAnimation")
                .frame(width: 120, height: 120)
            
            Image(.radiusIconShop)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .offset(y: -12)
        }
    }
}
