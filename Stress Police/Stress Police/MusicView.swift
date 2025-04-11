import SwiftUI
import AVKit

struct MusicView: View {
    let textColor: Color
    let backgroundColor: Color
    let secondaryBackgroundColor: Color

    @State private var isPlayingAudio: Bool = false
    @State private var audioCheckTimer: Timer?

    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Music")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
                .padding(.top, 70)

            Spacer()

            if isPlayingAudio {
                VStack(spacing: 20) {
                    AnimatedBarsView(color: textColor)
                        .frame(height: 60)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Playing Music")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(textColor)
                }
            } else {
                VStack(spacing: 16) {
                    Text("Play some relaxing music while you work")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(textColor.opacity(0.7))
                }
            }

            Spacer()

            // App Buttons (Icon + Label)
            HStack(spacing: 50) {
                VStack(spacing: 6) {
                    Button(action: { openApp("Spotify") }) {
                        Image("spotify")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                    Text("Spotify")
                        .font(.system(size: 14))
                        .foregroundColor(textColor)
                }

                VStack(spacing: 6) {
                    Button(action: { openApp("Apple Music") }) {
                        Image("applemusic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                    Text("Apple Music")
                        .font(.system(size: 14))
                        .foregroundColor(textColor)
                }
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            startAudioCheckTimer()
        }
        .onDisappear {
            stopAudioCheckTimer()
        }
    }

    // MARK: - Audio Detection Timer

    private func startAudioCheckTimer() {
        audioCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            isPlayingAudio = AVAudioSession.sharedInstance().isOtherAudioPlaying
        }
    }

    private func stopAudioCheckTimer() {
        audioCheckTimer?.invalidate()
        audioCheckTimer = nil
    }

    // MARK: - Open App

    private func openApp(_ app: String) {
        let spotifyURL = URL(string: "spotify://")!
        let musicURL = URL(string: "music://")!
        let url = app == "Spotify" ? spotifyURL : musicURL

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Animated Waveform Bars

struct AnimatedBarsView: View {
    let color: Color
    @State private var heights: [CGFloat] = Array(repeating: 12, count: 7)

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<heights.count, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 5, height: heights[i])
            }
        }
        .onAppear {
            animate()
        }
    }

    private func animate() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                heights = (0..<heights.count).map { _ in CGFloat.random(in: 10...45) }
            }
        }
    }
}
