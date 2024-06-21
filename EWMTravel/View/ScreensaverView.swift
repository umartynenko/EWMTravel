//
//  ScreensaverView.swift
//  GlitchTextEffect
//
//  Created by Юрий Мартыненко on 09.06.2024.
//

import SwiftUI


struct ScreensaverView: View {
    // View Properties
    @State private var trigger: Bool = false
    @State private var animationTriggered = false
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            GlitchImageView("globe.asia.australia.fill", trigger: trigger, width: 150, height: 150)
                .onAppear{
                    self.effectInterval()
                }
            GlitchTextView("EWM Travel", trigger: trigger)
                .onAppear{
                    self.effectInterval()
                }
            Text("Version: 1.0.1")
                .font(.system(size: 16, weight: .bold))
        }
        .padding()
    }
    
    @ViewBuilder
    func GlitchTextView(_ text: String, trigger: Bool) -> some View {
        ZStack {
            GlitchText(text: text, trigger: trigger) {
                LinearKeyframe(
                    GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
            }
            
            .font(.system(size: 60, weight: .semibold))
            
            GlitchText(text: text, trigger: trigger, shadow: .green) {
                LinearKeyframe(
                    GlitchFrame(top: 0, center: 5, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.3),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: -5, shadowOpacity: 0.5),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 0, center: 5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 0, center: -5, bottom: 0, shadowOpacity: 0.3),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
            }
            .font(.system(size: 100, weight: .semibold))
        }
    }
    
    @ViewBuilder
    func GlitchImageView(_ text: String, trigger: Bool, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            GlitchImage(text: text, trigger: trigger) {
                LinearKeyframe(
                    GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
            }
            .frame(width: width, height: height)
            
            GlitchImage(text: text, trigger: trigger, shadow: .green) {
                LinearKeyframe(
                    GlitchFrame(top: 0, center: 5, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.3),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: -5, shadowOpacity: 0.5),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 0, center: 5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 0, center: -5, bottom: 0, shadowOpacity: 0.3),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
                    duration: 0.1)
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
                    duration: 0.1
                )
                LinearKeyframe(GlitchFrame(), duration: 0.1)
            }
            .frame(width: width, height: height)
        }
    }
    
    func effectInterval() {
        guard !isAnimating else { return }
        isAnimating = true
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.trigger.toggle()
        }
    }
}
