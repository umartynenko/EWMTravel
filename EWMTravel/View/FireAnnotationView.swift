//
//  FireAnnotationView.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 05.06.2024.
//

import SwiftUI


struct FireAnnotationView: View {
    @State private var scale: CGFloat = 1.0
    
    let size: Double
    let level: String
    let scan: Double    // Ширина сканирования изображения в километрах. Это значение указывает на размер области, охваченной снимком.
    let track: Double   // Длина сканирования изображения в километрах. Это значение указывает на протяженность области, охваченной снимком.
    
    var body: some View {
        if level == "low" {
            let color: Color = .blue.opacity(0.5)
            
            return Circle()
                .fill(Color(color))
                .frame(width: (scan + track) * scale * size, height: (scan + track) * scale * size)
        } else {
            let color: Color = .red.opacity(0.5)
            
            return Circle()
                .fill(Color(color))
                .frame(width: (scan + track) * scale * size, height: (scan + track) * scale * size)
        }
    }
}

//struct PinAnnotationView: View {
//    var body: some View {
//        Image(systemName: "circle.fill")
//            .resizable()
//            .frame(width: 5, height: 5)
//            .foregroundColor(.red)
//    }
//}
