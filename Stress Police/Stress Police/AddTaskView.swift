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

    @State private var workPlanMode: WorkPlanMode = .defaultPlan
    @State private var customBlocks: [Task.WorkBlock] = []
    @State private var aiGeneratedBlocks: [Task.WorkBlock] = []
    @State private var isGeneratingAIPlan = false
    @State private var showObjectivePrompt = false
    @State private var aiObjective: String = ""
    @State private var showCustomPlanEditor = false

    enum WorkPlanMode: String, CaseIterable {
        case defaultPlan = "Use Default Plan"
        case aiPlan = "AI Generated Plan"
        case customPlan = "Custom Plan"
    }

    var body: some View {
        NavigationView {
            Form {
                taskInfoSection()
                optionalSection()
                workPlanSection()
                saveButtonSection()
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker("Select Deadline", selection: Binding(
                        get: { newTaskDeadline ?? Date() },
                        set: { newTaskDeadline = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .padding()

                    Button("Done", action: { showDatePicker = false })
                        .foregroundColor(Color(hex: "#007AFF"))
                }
                .padding()
            }
            .sheet(isPresented: $showFriendSelector) {
                VStack(spacing: 20) {
                    Text("Select Friends")
                        .font(.headline)

                    List(selection: Binding(
                        get: { Set(selectedFriends) },
                        set: { selectedFriends = Array($0) }
                    )) {
                        ForEach(allFriends, id: \.self) { friend in
                            Text(friend)
                        }
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
            .sheet(isPresented: $showCustomPlanEditor) {
                CustomPlanEditor(blocks: $customBlocks)
            }
            .alert("What is the main objective of this task?", isPresented: $showObjectivePrompt, actions: {
                TextField("e.g. Prepare a marketing presentation", text: $aiObjective)
                Button("Generate Plan") { generateAIPlan() }
                Button("Cancel", role: .cancel) {}
            })
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

    private func taskInfoSection() -> some View {
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
    }

    private func optionalSection() -> some View {
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
    }

    private func workPlanSection() -> some View {
        Section(header: Text("Work Plan")) {
            Picker("Plan Type", selection: $workPlanMode) {
                ForEach(WorkPlanMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                }
            }
            .pickerStyle(.menu)

            if workPlanMode == .aiPlan {
                if isGeneratingAIPlan {
                    HStack(spacing: 6) {
                        ProgressView()
                        Text("Generating AI Plan...")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                } else {
                    Button("AI Generate Work Plan") {
                        showObjectivePrompt = true
                    }
                }

                if !aiGeneratedBlocks.isEmpty {
                    ForEach(aiGeneratedBlocks.indices, id: \.self) { index in
                        let block = aiGeneratedBlocks[index]
                        Text("• \(formatBlock(block))" + (block.label != nil ? " → \(block.label!)" : ""))
                    }
                }
            }

            if workPlanMode == .customPlan {
                Button("Edit Custom Plan") {
                    showCustomPlanEditor = true
                }

                if !customBlocks.isEmpty {
                    ForEach(customBlocks.indices, id: \.self) { index in
                        let block = customBlocks[index]
                        Text("• \(formatBlock(block))" + (block.label != nil ? " → \(block.label!)" : ""))
                    }
                }
            }
        }
    }

    private func saveButtonSection() -> some View {
        Section {
            Button("Save Task") {
                guard !newTaskTitle.isEmpty else { return }

                let schedule = getCurrentSchedule()
                print("💾 Saving task with schedule:", schedule) // DEBUG
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

    private func getCurrentSchedule() -> [Task.WorkBlock] {
        switch workPlanMode {
        case .defaultPlan:
            let deadline = newTaskDeadline ?? Date().addingTimeInterval(3600)
            return recommendWorkSchedule(newTaskTitle, deadline, selectedPriority)
        case .aiPlan:
            return aiGeneratedBlocks
        case .customPlan:
            return customBlocks
        }
    }

    private func generateAIPlan() {
        guard let deadline = newTaskDeadline else { return }
        isGeneratingAIPlan = true

        let dummyTask = Task(title: newTaskTitle, deadline: deadline)

        OpenAIService().fetchSmartSchedule(
            tasks: [dummyTask],
            workStart: 9,
            workEnd: 17,
            objective: aiObjective
        ) { generatedBlocks in
            DispatchQueue.main.async {
                self.isGeneratingAIPlan = false
                if let blocks = generatedBlocks {
                    print("✅ AI Plan Blocks received:", blocks) // DEBUG
                    self.aiGeneratedBlocks = blocks
                } else {
                    print("❌ Failed to parse AI schedule")
                }
            }
        }
    }



    private func formatBlock(_ block: Task.WorkBlock) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let start = Calendar.current.date(bySettingHour: Int(block.startHour), minute: Int((block.startHour * 60).truncatingRemainder(dividingBy: 60)), second: 0, of: Date()) ?? Date()
        let end = Calendar.current.date(bySettingHour: Int(block.endHour), minute: Int((block.endHour * 60).truncatingRemainder(dividingBy: 60)), second: 0, of: Date()) ?? Date()

        let duration = Int((block.endHour - block.startHour) * 60)
        return "\(formatter.string(from: start)) - \(formatter.string(from: end)) (\(duration) min)"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Custom Plan Editor

struct CustomPlanEditor: View {
    @Binding var blocks: [Task.WorkBlock]
    @State private var startHour: Double = 9
    @State private var endHour: Double = 10

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Start Time: \(formatHour(startHour))")
                    Slider(value: $startHour, in: 0...23.75, step: 0.25)
                }

                VStack(alignment: .leading) {
                    Text("End Time: \(formatHour(endHour))")
                    Slider(value: $endHour, in: 0.25...24, step: 0.25)
                }

                Button(action: {
                    guard endHour > startHour else { return }
                    blocks.append(Task.WorkBlock(
                        startHour: startHour,
                        endHour: endHour,
                        from: .custom
                    ))
                }) {
                    Text("Add Block")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#007AFF"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                List {
                    ForEach(blocks.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text("\(formatHour(blocks[index].startHour)) - \(formatHour(blocks[index].endHour))")
                                .font(.subheadline)

                            TextField("Label", text: Binding(
                                get: { blocks[index].label ?? "Block \(index + 1)" },
                                set: { newValue in
                                    blocks[index].label = newValue.isEmpty ? nil : newValue
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.caption)
                        }
                    }
                    .onDelete { indexSet in
                        blocks.remove(atOffsets: indexSet)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Custom Work Plan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func formatHour(_ hour: Double) -> String {
        let totalMinutes = Int(hour * 60)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let components = DateComponents(hour: h, minute: m)
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}
