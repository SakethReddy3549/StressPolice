import SwiftUI

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Binding var tasks: [Task]
    @Binding var newTaskTitle: String
    @Binding var newTaskDeadline: Date?
    @Binding var isMenuOpen: Bool
    @Binding var selectedView: String
    
    let logoutAction: () -> Void
    let textColor: Color
    let backgroundColor: Color
    let secondaryBackgroundColor: Color

    var body: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 40)

            Text("Settings")
                .font(.title2.weight(.semibold))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .center)

            // MARK: - Theme Toggle
            Button(action: {
                withAnimation {
                    isDarkMode.toggle()
                }
            }) {
                HStack {
                    Text("Theme")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(textColor)
                    Spacer()
                    Text(isDarkMode ? "Dark" : "Light")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(secondaryBackgroundColor)
                .cornerRadius(10)
            }
            .padding(.horizontal)

            // MARK: - Reset Tasks
            Button(action: {
                withAnimation {
                    tasks = []
                    newTaskTitle = ""
                    newTaskDeadline = nil
                    selectedView = "Tasks"
                    isMenuOpen = false
                }
            }) {
                Text("Reset All Tasks")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // MARK: - Logout
            Button(action: {
                withAnimation {
                    logoutAction()
                    isMenuOpen = false
                }
            }) {
                Text("Logout")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 40)
        .frame(maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
    }
}
