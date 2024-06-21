//
//  ReusableFunctionsApplication.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 20.06.2024.
//

import Foundation
import Lottie
import SwiftUI


func lottieAnimation(forResource: String) -> some View{
    GeometryReader {_ in
        if let bundle = Bundle.main.path(forResource: forResource, ofType: "json") {
            LottieView {
                await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
            }
            .playing(loopMode: .loop)
        }
    }
}
