import SwiftUI

struct PlansView: View {
    @Binding var tasks: [Task]
    @Binding var showDatePicker: Bool
    @Binding var selectedDate: Date

    let textColor: Color
    let backgroundColor: Color
    let saveTasks: ([Task]) -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Button(action: { showDatePicker = true }) {
                    Text("Select Date")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#007AFF"))
                        .cornerRadius(8)
                        .padding(.top, 60)
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        Spacer().frame(height: 20)

                        dailySection(label: "Today", date: Date())

                        dailySection(label: "Tomorrow", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)

                        if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) &&
                            !Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) {
                            dailySection(label: dateFormatter.string(from: selectedDate), date: selectedDate)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .background(backgroundColor)
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Plans")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showDatePicker) {
            VStack(spacing: 20) {
                DatePicker("Select a Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()

                Button("Done") {
                    showDatePicker = false
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#007AFF"))
            }
            .padding()
            .background(backgroundColor)
        }
    }

    // MARK: - Daily Section

    private func dailySection(label: String, date: Date) -> some View {
        let matchingTasks = tasks.filter {
            Calendar.current.isDate($0.deadline, inSameDayAs: date)
        }
        let completion = matchingTasks.isEmpty ? 0 : Double(matchingTasks.filter { $0.isCompleted }.count) / Double(matchingTasks.count) * 100

        return VStack(alignment: .leading, spacing: 16) {
            Text("\(label), \(dateFormatter.string(from: date))")
                .font(.title3.weight(.semibold))
                .foregroundColor(textColor)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Text("\(Int(completion)) of 100% done")
                    .font(.subheadline)
                    .foregroundColor(textColor)

                ProgressView(value: completion, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#007AFF")))
            }
            .padding(.horizontal, 20)

            VStack(spacing: 16) {
                ForEach(matchingTasks) { task in
                    taskRow(task)
                        .padding(.horizontal, 20)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                    withAnimation {
                                        tasks.remove(at: index)
                                        saveTasks(tasks)
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    // MARK: - Task Row

    private func taskRow(_ task: Task) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(task.title)
                    .font(.system(size: 18))
                    .foregroundColor(textColor)
                    .strikethrough(task.isCompleted)
                Spacer()
                Text(task.deadline > Date() ? formatDueTime(task.deadline) : "Time Up")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }

            Text("Priority: \(task.priority.rawValue)")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }

    private func formatDueTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
