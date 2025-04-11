import SwiftUI

struct SchedulePreviewView: View {
    let startDate: Date
    let dueDate: Date
    let schedule: [Task.WorkBlock]
    @Binding var isPresented: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            Text("Work Schedule Preview")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)

            ScrollView(.horizontal, showsIndicators: true) {
                GeometryReader { geometry in
                    let totalTime = dueDate.timeIntervalSince(startDate)
                    let timelineWidth = max(geometry.size.width * 2, totalTime / 3600 * 50)
                    let widthPerSecond = timelineWidth / totalTime

                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 4)
                            .foregroundColor(.gray.opacity(0.4))
                            .frame(width: timelineWidth)

                        ForEach(schedule.indices, id: \.self) { index in
                            let block = schedule[index]
                            let offset = block.startTime.timeIntervalSince(startDate) * widthPerSecond

                            VStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 10, height: 10)
                                    .offset(y: -20)

                                Text(formatDate(block.startTime))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .frame(width: 80)
                                    .rotationEffect(.degrees(-30))
                                    .offset(y: 5)

                                Text(formatDuration(block.duration))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .frame(width: 80)
                                    .rotationEffect(.degrees(-30))
                                    .offset(y: 20)
                            }
                            .position(x: offset + 20, y: 60)
                        }
                    }
                    .frame(width: timelineWidth, height: 140)
                }
                .frame(height: 150)
            }
            .padding(.horizontal)

            HStack {
                Text("Now")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(formatDate(dueDate))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Button("Close") {
                isPresented = false
            }
            .foregroundColor(Color(hex: "#007AFF"))
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return minutes < 60
            ? "\(minutes) min"
            : String(format: "%.1f hr", duration / 3600)
    }
}
