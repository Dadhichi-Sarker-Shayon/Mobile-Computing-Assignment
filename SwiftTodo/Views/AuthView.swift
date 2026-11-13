//
//  AuthView.swift
//  SwiftTodo
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 0)

            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.tint)
                    .symbolRenderingMode(.hierarchical)

                Text("SwiftTodo")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text(isSignUp ? "Create an account to get started."
                               : "Welcome back. Sign in to continue.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 14) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)

                SecureField("Password", text: $password)
                    .textContentType(isSignUp ? .newPassword : .password)
                    .submitLabel(.go)
                    .onSubmit { submit() }
            }
            .textFieldStyle(.roundedBorder)

            if let message = auth.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            Button(action: submit) {
                HStack {
                    Spacer()
                    if auth.isLoading {
                        ProgressView()
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.headline)
                    }
                    Spacer()
                }
            }
            .disabled(auth.isLoading)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)

            Spacer(minLength: 0)

            Button {
                isSignUp.toggle()
                auth.errorMessage = nil
            } label: {
                Text(isSignUp ? "Already have an account? **Sign In**"
                              : "New to SwiftTodo? **Create an account**")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .disabled(auth.isLoading)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 440)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .animation(.easeInOut(duration: 0.2), value: isSignUp)
        .animation(.easeInOut(duration: 0.2), value: auth.errorMessage)
    }

    private func submit() {
        Task {
            if isSignUp {
                await auth.signUp(email: email, password: password)
            } else {
                await auth.signIn(email: email, password: password)
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
