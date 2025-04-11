import SwiftUI

struct AddTaskView: View {
    @Binding var newTaskTitle: String
    @Binding var newTaskDeadline: Date?
    let onSave: (String, Date?, Task.Priority, [Task.WorkBlock], [String]?) -> Void
    let recommendWorkSchedule: (String, Date, Task.Priority) -> [Task.WorkBlock]

    @Environment(\.dismiss) var dismiss
    @State private var selectedPriority: Task.Priority = .medium
    @State private var showDatePicker = false
    @State private var showFriendSelector = false
    @State private var selectedFriends: [String] = []
    @State private var allFriends: [String] = ["Anthony", "Sanjana"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Info")) {
                    TextField("Title", text: $newTaskTitle)

                    Button("Select Deadline") {
                        showDatePicker.toggle()
                    }

                    if let date = newTaskDeadline {
                        Text("Deadline: \(formattedDate(date))")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }

                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                        }
                    }
                }

                Section(header: Text("Optional")) {
                    Button("Group Task") {
                        showFriendSelector.toggle()
                    }

                    if !selectedFriends.isEmpty {
                        Text("With: \(selectedFriends.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Section {
                    Button("Save Task") {
                        guard !newTaskTitle.isEmpty else { return }
                        let deadline = newTaskDeadline ?? Date().addingTimeInterval(3600)
                        let schedule = recommendWorkSchedule(newTaskTitle, deadline, selectedPriority)
                        onSave(newTaskTitle, newTaskDeadline, selectedPriority, schedule, selectedFriends.isEmpty ? nil : selectedFriends)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#007AFF"))
                    .cornerRadius(8)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("Select Deadline", selection: Binding(
                        get: { newTaskDeadline ?? Date() },
                        set: { newTaskDeadline = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .padding()

                    Button("Done") {
                        showDatePicker = false
                    }
                    .foregroundColor(Color(hex: "#007AFF"))
                }
                .padding()
            }
            .sheet(isPresented: $showFriendSelector) {
                VStack(spacing: 20) {
                    Text("Select Friends")
                        .font(.headline)

                    List(allFriends, id: \.self, selection: Binding(
                        get: { Set(selectedFriends) },
                        set: { selectedFriends = Array($0) }
                    )) { friend in
                        Text(friend)
                    }
                    .environment(\.editMode, .constant(.active))

                    Button("Confirm") {
                        showFriendSelector = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#007AFF"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color(hex: "#007AFF"))
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
