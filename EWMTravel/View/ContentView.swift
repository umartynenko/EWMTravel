//
//  ContentView.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 20.06.2024.
//

import SwiftUI
import Firebase
import Combine


struct ContentView: View {
    @State private var showScreensaver: Bool = true
    @State private var timerCancellable: AnyCancellable?
    
    @AppStorage("log_status") private var logStatus: Bool = false
    
    var body: some View {
        if showScreensaver {
            ScreensaverView()
                .onAppear{
                    screensaverDurationTime()
                }
        } else {
            if logStatus {
                EWMTravelView()
            } else {
                Login()
            }
        }
    }
    
    private func screensaverDurationTime() {
        // Создать таймер с задержкой в несколько секунд
        timerCancellable = Timer.publish(every: 6, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // По истечении времени изменить состояние, чтобы переключиться на ContentView
                showScreensaver = false
            }
    }
}


#Preview {
    ContentView()
}
