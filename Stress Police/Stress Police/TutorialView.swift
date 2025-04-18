import SwiftUI

struct TutorialView: View {
    @Binding var isFirstLogin: Bool

    var body: some View {
        TabView {
            tutorialPage(title: "Welcome to Stress Police", description: "An app that helps you manage tasks and relax your mind.", image: "onboarding1")
            tutorialPage(title: "Smart Task Planning", description: "Let AI generate optimal work blocks for your deadlines.", image: "onboarding2")
            tutorialPage(title: "Take Breaks", description: "Relax and recharge with our animated break feature.", image: "onboarding3")
            tutorialPage(title: "Stay Synced", description: "Use the chat and music sections to stay balanced.", image: "onboarding4")

            VStack(spacing: 20) {
                Text("You're all set!")
                    .font(.title)
                    .fontWeight(.bold)

                Button("Get Started") {
                    UserDefaults.standard.set(false, forKey: "isFirstLogin")
                    isFirstLogin = false
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding()
        }
        .tabViewStyle(PageTabViewStyle())
        .background(Color(hex: "#212121").ignoresSafeArea())
    }

    func tutorialPage(title: String, description: String, image: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 240)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            Spacer()
        }
        .padding()
    }
}

