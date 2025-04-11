import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var isDarkMode: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var goToSignup = false

    private var backgroundColor: Color {
        isDarkMode ? Color(hex: "#212121") : Color(hex: "#F5F5F5")
    }

    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer().frame(height: 120)

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(textColor)
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(textColor)
                        .padding(.horizontal)

                    Button("Login") {
                        login()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color(hex: "#007AFF"))
                    .cornerRadius(8)

                    Button(action: {
                        goToSignup = true
                    }) {
                        Text("Don't have an account? Sign up")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }

                    Spacer()
                }
                .navigationDestination(isPresented: $goToSignup) {
                    SignupView(showLogin: .constant(true), isDarkMode: $isDarkMode)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both email and password."
            showAlert = true
            return
        }

        let storedEmail = UserDefaults.standard.string(forKey: "registeredEmail")
        let storedPassword = UserDefaults.standard.string(forKey: "registeredPassword")

        if email == storedEmail && password == storedPassword {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            isLoggedIn = true
        } else {
            alertMessage = "Incorrect email or password."
            showAlert = true
        }
    }
}
