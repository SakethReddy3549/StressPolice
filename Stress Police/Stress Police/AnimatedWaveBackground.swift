import SwiftUI

struct AnimatedWaveBackground: View {
    @State private var waveOffset = Angle(degrees: 0)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Wave(offset: waveOffset, amplitude: 0.2)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: geometry.size.height / 2)
                    .offset(y: geometry.size.height / 2)
                    .onAppear {
                        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                            waveOffset = Angle(degrees: 360)
                        }
                    }
            }
        }
    }
}

struct Wave: Shape {
    var offset: Angle
    var amplitude: CGFloat

    var animatableData: Angle.AnimatableData {
        get { offset.radians }
        set { offset = Angle(radians: newValue) }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let waveHeight = rect.height * amplitude
            let wavelength = rect.width / 1.5

            path.move(to: .zero)
            for x in stride(from: 0, through: rect.width, by: 1) {
                let relativeX = x / wavelength
                let sine = sin(relativeX + CGFloat(offset.radians))
                let y = waveHeight * sine + rect.height / 2
                path.addLine(to: CGPoint(x: x, y: y))
            }

            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
    }
}

