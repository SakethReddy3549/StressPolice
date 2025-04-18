import SwiftUI

@main
struct StressPoliceApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var showLogin = false
    @State private var showSignup = false
    @State private var isDarkMode = true
    @State private var hasSetupProfile = UserDefaults.standard.bool(forKey: "hasSetupProfile")
    @State private var isFirstLogin = UserDefaults.standard.bool(forKey: "isFirstLogin")

    @State private var tempName = ""
    @State private var tempBio = ""
    @State private var tempStartHour = 9
    @State private var tempEndHour = 17

    private var backgroundColor: Color {
        isDarkMode ? Color(hex: "#212121") : Color(hex: "#F5F5F5")
    }

    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            if isLoggedIn && hasSetupProfile && isFirstLogin {
                TutorialView(isFirstLogin: $isFirstLogin)
            } else if isLoggedIn && hasSetupProfile {
                ContentView(
                    isDarkMode: $isDarkMode,
                    isLoggedIn: $isLoggedIn,
                    logoutAction: {
                        isLoggedIn = false
                        showLogin = false
                        showSignup = false
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    }
                )
            } else if isLoggedIn && !hasSetupProfile {
                ProfileView(
                    name: $tempName,
                    bio: $tempBio,
                    isEditingName: .constant(true),
                    isEditingBio: .constant(true),
                    workStartHour: $tempStartHour,
                    workEndHour: $tempEndHour,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    saveProfile: { name, bio, start, end in
                        UserDefaults.standard.set(name, forKey: "name")
                        UserDefaults.standard.set(bio, forKey: "bio")
                        UserDefaults.standard.set(start, forKey: "workStartHour")
                        UserDefaults.standard.set(end, forKey: "workEndHour")
                        UserDefaults.standard.set(true, forKey: "hasSetupProfile")
                        UserDefaults.standard.set(true, forKey: "isFirstLogin") // ✅ tutorial must follow this
                        isLoggedIn = true
                        hasSetupProfile = true
                        isFirstLogin = true // ✅ trigger tutorial
                    }
                )
            } else if showLogin {
                LoginView(isLoggedIn: $isLoggedIn, isDarkMode: $isDarkMode)
            } else if showSignup {
                SignupView(showLogin: $showLogin, isDarkMode: $isDarkMode)
            } else {
                welcomeScreen
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private var welcomeScreen: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Stress Police")
                .font(.custom("Avenir", size: 36))
                .foregroundColor(textColor)

            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Text("Existing user?")
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                    Button(action: { showLogin = true }) {
                        Text("Login")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color(hex: "#4CAF50"))
                            .cornerRadius(10)
                    }
                }

                VStack(spacing: 12) {
                    Text("New user?")
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                    Button(action: {
                        showSignup = true
                        UserDefaults.standard.set(true, forKey: "isFirstLogin")
                    }) {
                        Text("Signup")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color(hex: "#F44336"))
                            .cornerRadius(10)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.3), value: showLogin || showSignup)
    }
}
