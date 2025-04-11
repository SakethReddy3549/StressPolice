import SwiftUI

struct ProfileView: View {
    @Binding var name: String
    @Binding var bio: String
    @Binding var isEditingName: Bool
    @Binding var isEditingBio: Bool
    @Binding var workStartHour: Int
    @Binding var workEndHour: Int

    let textColor: Color
    let backgroundColor: Color
    let saveProfile: (String, String, Int, Int) -> Void

    @State private var showAlert = false
    @State private var showEditButton = UserDefaults.standard.bool(forKey: "hasSetupProfile")
    @State private var email: String = UserDefaults.standard.string(forKey: "registeredEmail") ?? ""

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 40) {
                        Spacer(minLength: 40)

                        Text("Profile")
                            .font(.title2)
                            .foregroundColor(textColor)

                        VStack(alignment: .leading, spacing: 30) {
                            // Name
                            HStack {
                                if isEditingName {
                                    TextField("Name", text: $name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .foregroundColor(textColor)
                                } else {
                                    Text("Name: \(name)")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(textColor)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Bio
                            HStack {
                                if isEditingBio {
                                    TextField("Bio (optional)", text: $bio)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .foregroundColor(textColor)
                                } else {
                                    Text("Bio: \(bio)")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Email
                            HStack {
                                Text("Email: \(email)")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal)

                            // Work Hours
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Working Hours")
                                    .font(.headline)
                                    .foregroundColor(textColor)

                                Stepper("Start: \(workStartHour):00", value: $workStartHour, in: 0...23)
                                    .disabled(!isEditingName && !isEditingBio)

                                Stepper("End: \(workEndHour):00", value: $workEndHour, in: 1...24)
                                    .disabled(!isEditingName && !isEditingBio)
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 20)

                        // Save or Edit
                        if isEditingName || isEditingBio || !showEditButton {
                            Button("Save") {
                                if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    showAlert = true
                                } else {
                                    saveProfile(name, bio, workStartHour, workEndHour)
                                    isEditingName = false
                                    isEditingBio = false
                                    showEditButton = true
                                    UserDefaults.standard.set(true, forKey: "hasSetupProfile")
                                    UserDefaults.standard.set(false, forKey: "isFirstLogin")
                                    // No dismiss() needed; RootView handles navigation
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color(hex: "#007AFF"))
                            .cornerRadius(8)
                        } else {
                            Button("Edit Profile") {
                                isEditingName = true
                                isEditingBio = true
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color(hex: "#007AFF"))
                            .cornerRadius(8)
                        }

                        // Delete Account
                        Button("Delete Account") {
                            deleteAccount()
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Missing Name"), message: Text("Name cannot be empty."), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Delete Account
    private func deleteAccount() {
        UserDefaults.standard.removeObject(forKey: "registeredEmail")
        UserDefaults.standard.removeObject(forKey: "registeredPassword")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "bio")
        UserDefaults.standard.removeObject(forKey: "tasks")
        UserDefaults.standard.removeObject(forKey: "chatMessages")
        UserDefaults.standard.removeObject(forKey: "workStartHour")
        UserDefaults.standard.removeObject(forKey: "workEndHour")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set(false, forKey: "hasSetupProfile")

        // Restart to RootView
        if let scene = UIApplication.shared.connectedScenes.first,
           let window = (scene as? UIWindowScene)?.windows.first {
            window.rootViewController = UIHostingController(rootView: RootView())
            window.makeKeyAndVisible()
        }
    }
}
