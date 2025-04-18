import SwiftUI

struct SignupView: View {
    @Binding var showLogin: Bool
    @Binding var isDarkMode: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false

    private var backgroundColor: Color {
        isDarkMode ? Color(hex: "#212121") : Color(hex: "#F5F5F5")
    }
    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer().frame(height: 100)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(textColor)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(textColor)
                    .padding(.horizontal)

                Button("Sign Up") {
                    signup()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 200)
                .background(Color(hex: "#007AFF"))
                .cornerRadius(8)

                Button(action: {
                    showLogin = true
                    // This line ensures the SignupView is dismissed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        showLogin = true
                    }
                }) {
                    Text("Already have an account? Login")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }

                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#4CAF50"))

                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Signup Error"), message: Text("Both fields must be filled."), dismissButton: .default(Text("OK")))
        }
    }

    private func signup() {
        guard !email.isEmpty, !password.isEmpty else {
            showAlert = true
            return
        }

        UserDefaults.standard.set(email, forKey: "registeredEmail")
        UserDefaults.standard.set(password, forKey: "registeredPassword")
        UserDefaults.standard.set(false, forKey: "hasSetupProfile") // will force ProfileView after login
        UserDefaults.standard.set(true, forKey: "isFirstLogin")     // ensure tutorial shows on first login
        showLogin = true
    }
}
