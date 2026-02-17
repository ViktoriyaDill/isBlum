//
//  MapView.swift
//  isBlum
//
//  Created by Пользователь on 12/02/2026.
//

import Foundation
import SwiftUI

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
            LottieView(name: "pulseAnimation", play: .constant(true))
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
            LottieView(name: "pulseAnimation", play: .constant(true))
                .frame(width: 120, height: 120)
            
            Image(.radiusIconShop)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .offset(y: -12)
        }
    }
}
