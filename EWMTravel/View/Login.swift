//
//  Login.swift
//  EWMTravel
//
//  Created by Юрий Мартыненко on 19.06.2024.
//

import SwiftUI
import Firebase
import Lottie
import Combine


struct Login: View {
    // View Properties
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var reEnterPassword: String = ""
    @State private var activeTab: Tab = .login
    @State private var isLoading: Bool = false
    @State private var showEmailverificationView: Bool = false

    // Alert Properties
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    // Forgot Password Properties
    @State private var showResetAlert: Bool = false
    @State private var resetEmailAddress: String = ""
    
    @AppStorage("log_status") private var logStatus: Bool = false
    
    
    var body: some View {
            NavigationStack {
                VStack(spacing: 6, content: {
                    lottieAnimation(forResource: "GlobeAnimation")
                        .frame(width: 260, height: 260)
                })
                .frame(width: 100, height: 100)
                List {
                    Section {
                        TextField("Адрес электронной почты", text: $emailAddress)
                            .keyboardType(.emailAddress)
                            .onChange(of: emailAddress, { oldValue, newValue in
                                emailAddress = newValue.lowercased()
                            })
                            .customTextField("envelope")
                        SecureField("Пароль", text: $password)
                            .customTextField("person.badge.key", 0, activeTab == .login ? 10 : 0)
                        
                        if activeTab == .signApp {
                            SecureField("Повторно введите пароль", text: $reEnterPassword)
                                .customTextField("person.badge.key", 0, activeTab != .login ? 10 : 0)
                        }
                    } header: {
                        Picker("", selection: $activeTab) {
                            ForEach(Tab.allCases, id: \.rawValue) {
                                Text($0.rawValue)
                                    .tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowInsets(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
                        .listRowSeparator(.hidden)
                    } footer: {
                        VStack(alignment: .trailing, spacing: 12) {
                            if activeTab == .login {
                                Button("Забыли пароль?") {
                                    showResetAlert = true
                                }
                                .font(.caption)
                                .tint(Color.accentColor)
                            }
                            Button {
                                loginAndSignUp()
                            } label: {
                                HStack(spacing: 12) {
                                    Text(activeTab == .login ? "Войти" : "Зарегистрироваться")
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.callout)
                                }
                                .padding(.horizontal, 10)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .disabled(buttonStatus)
                            .showLoadingIndicator(isLoading)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .listRowInsets(.init(top: 15, leading: 0, bottom: 0, trailing: 0))
                    }
                    .disabled(isLoading)
                }
                .navigationTitle("EWMTravel")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.insetGrouped)
                .animation(.snappy, value: activeTab)
            }
            .sheet(isPresented: $showEmailverificationView, content: {
                emailVerificationView()
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled()
            })
            .alert(alertMessage, isPresented: $showAlert, actions: {})
            .alert("Сброс пароля", isPresented: $showResetAlert, actions: {
                TextField("Адрес электронной почты", text: $resetEmailAddress)
                    .keyboardType(.emailAddress)
                    .onChange(of: emailAddress) { oldValue, newValue in
                        emailAddress = newValue.lowercased()
                    }
                
                Button("Отправить ссылку для сброса", role: .destructive, action: sendResetLink)
                Button("Отмена", role: .cancel) {
                    resetEmailAddress = ""
                }
            }, message: {
                Text("Введите адрес электронной почты")
            })
            .onChange(of: activeTab, initial: false) { oldValue, newValue in
                password = ""
                reEnterPassword = ""
            }
    }
    
    //Email Verification View
    @ViewBuilder
    func emailVerificationView() -> some View {
        VStack(spacing: 6, content: {
            lottieAnimation(forResource: "EmailAnimation")
            
            Text("Проверка")
                .font(.title.bold())
            Text("Мы отправили письмо с подтверждением на ваш адрес электронной почты. Пожалуйста, подтвердите, чтобы продолжить.")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.horizontal, 25)
        })
        .overlay(alignment: .topTrailing, content: {
            Button("Отмена") {
                showEmailverificationView = false
            }
            .padding(15)
        })
        .padding(.bottom, 15)
        .onReceive(Timer.publish(every: 2, on: .main, in: .default).autoconnect(), perform: { _ in
            if let user = Auth.auth().currentUser {
                user.reload()
                if user.isEmailVerified {
                    // Email Successfully Verified
                    showEmailverificationView = false
                    logStatus = true
                }
            }
        })
    }
    
    func sendResetLink() {
        Task {
            do {
                if resetEmailAddress.isEmpty {
                    await presentAlert("Пожалуйста введите адрес электронной почты.")
                    return
                }
                
                isLoading = true
                
                try await Auth.auth().sendPasswordReset(withEmail: resetEmailAddress)
                
                await presentAlert("Пожалуйста, проверьте свой почтовый ящик и следуйте инструкциям по сбросу пароля!")
                
                resetEmailAddress = ""
                isLoading = false
            } catch {
                await presentAlert(error.localizedDescription)
            }
        }
    }
    
    func loginAndSignUp() {
        Task {
            isLoading = true
            do {
                if activeTab == .login {
                    // Logging in
                    let result = try await Auth.auth().signIn(withEmail: emailAddress, password: password)
                    
                    if result.user.isEmailVerified {
                        // Verified User
                        // Redirect to Home View
                        logStatus = true
                    } else {
                        // Send Verification Email and Presenting Verification View
                        try await result.user.sendEmailVerification()
                        
                        showEmailverificationView = true
                    }
                } else {
                    // Creating New Account
                    if password == reEnterPassword {
                        let result = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
                        
                        // Sending Verification Email
                        try await result.user.sendEmailVerification()
                        
                        // Showing Email Verification View
                        showEmailverificationView = true
                    } else {
                        await presentAlert("Неверный пароль")
                    }
                }
            } catch {
                await presentAlert(error.localizedDescription)
            }
        }
    }
    
    // Presenting Alert
    func presentAlert(_ message: String) async {
        await MainActor.run {
            alertMessage = message
            showAlert = true
            isLoading = false
            resetEmailAddress = ""
        }
    }
    
    // Tab Type
    enum Tab: String, CaseIterable {
        case login = "Войти"
        case signApp = "Зарегистрироваться"
    }
    
    // Button Status
    var buttonStatus: Bool {
        if activeTab == .login {
            return emailAddress.isEmpty || password.isEmpty
        }
        
        return emailAddress.isEmpty || password.isEmpty || reEnterPassword.isEmpty
    }
}


fileprivate extension View {
    @ViewBuilder
    func showLoadingIndicator(_ status: Bool) -> some View {
        self
            .animation(.snappy) { content in
                content
                    .opacity(status ? 0 : 1)
            }
            .overlay {
                if status {
                    ZStack(content: {
                        Capsule()
                            .fill(.bar)
                        
                        ProgressView()
                    })
                }
            }
    }
    
    @ViewBuilder
    func customTextField(_ icon: String? = nil, _ paddingTop: CGFloat = 0, _ paddintBottom: CGFloat = 0) -> some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            self
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(.bar, in: .rect(cornerRadius: 10))
        .padding(.horizontal, 15)
        .padding(.top, paddingTop)
        .padding(.bottom, paddintBottom)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
    
}


#Preview {
    Login()
}
