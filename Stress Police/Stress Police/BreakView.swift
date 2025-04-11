import SwiftUI

struct BreakView: View {
    @Binding var isPresented: Bool
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer? = nil
    @State private var isBreakActive = false
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 5 // default to 5 minutes

    var body: some View {
        ZStack {
            AnimatedWaveBackground()
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Break Time")
                    .font(.largeTitle.bold())
                    .foregroundColor(.black)

                if isBreakActive {
                    Text(timeString)
                        .font(.system(size: 48, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)

                    Button("End Break", action: endBreak)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                } else {
                    VStack(spacing: 15) {
                        HStack {
                            Text("Hours")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Picker("Hours", selection: $selectedHours) {
                                ForEach(0..<6, id: \.self) { Text("\($0) h") }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 100)
                        }

                        HStack {
                            Text("Minutes")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Picker("Minutes", selection: $selectedMinutes) {
                                ForEach(0..<60, id: \.self) { Text("\($0) min") }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 100)
                        }
                    }
                    .padding(.horizontal, 40)

                    Button("Start Break") {
                        timeRemaining = selectedHours * 3600 + selectedMinutes * 60
                        if timeRemaining > 0 {
                            isBreakActive = true
                            startTimer()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.green.opacity(0.9))
                    .cornerRadius(10)
                }
            }
            .padding(.bottom, 30)
        }
        .onDisappear(perform: stopTimer)
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endBreak()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func endBreak() {
        stopTimer()
        isPresented = false
        isBreakActive = false
    }
}
