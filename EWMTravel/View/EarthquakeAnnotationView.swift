//
//  EarthquakeAnnotationView.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 01.06.2024.
//

import SwiftUI


struct EarthquakeAnnotationView: View {
    @State private var scale: CGFloat = 1.0
    
    let magnitude: Double
    
    var body: some View {
        let size: Double = magnitude < 0 ? 0 : magnitude * 5
        let color1: Color
        let color2: Color
        
        switch magnitude {
            case -100..<0:
                color1 = .white.opacity(0)
                color2 = .white.opacity(0)
            case 0..<4:
                color1 = .white
                color2 = Color("weak_3")
            case 4..<6:
                color1 = Color("moderate_4")
                color2 = Color("quiteStrong_5")
            case 6..<7:
                color1 = Color("strong_6")
                color2 = Color("strong_6")
            case 7..<8:
                color1 = Color("veryStrong_7")
                color2 = Color("veryStrong_7")
            default:
                color1 = Color("destructive_8")
                color2 = Color("catastrophe_11")
        }
        
        return Circle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [color1, color2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(width: size * scale, height: size * scale)
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .onAppear {
//                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
//                    scale = 1.5
//                }
            }
    }
}


