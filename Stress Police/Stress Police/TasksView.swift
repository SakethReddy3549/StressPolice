import SwiftUI

struct TasksView: View {
    @Binding var tasks: [Task]
    @Binding var showAddTaskSheet: Bool
    @Binding var newTaskTitle: String
    @Binding var newTaskDeadline: Date?
    let textColor: Color
    let backgroundColor: Color
    let completionPercentage: Double
    let saveTasks: ([Task]) -> Void
    let scheduleTaskNotifications: (Task) -> Void
    let recommendWorkSchedule: (String, Date, Task.Priority, (start: Int, end: Int)) -> [Task.WorkBlock]
    let timeLeftString: (Date) -> String
    let workStartHour: Int
    let workEndHour: Int

    @State private var expandedTaskIDs: Set<UUID> = []
    @State private var showBreakScreen = false

    init(
        tasks: Binding<[Task]>,
        showAddTaskSheet: Binding<Bool>,
        newTaskTitle: Binding<String>,
        newTaskDeadline: Binding<Date?>,
        textColor: Color,
        backgroundColor: Color,
        completionPercentage: Double,
        saveTasks: @escaping ([Task]) -> Void,
        scheduleTaskNotifications: @escaping (Task) -> Void,
        recommendWorkSchedule: @escaping (String, Date, Task.Priority, (start: Int, end: Int)) -> [Task.WorkBlock],
        timeLeftString: @escaping (Date) -> String,
        workStartHour: Int,
        workEndHour: Int
    ) {
        self._tasks = tasks
        self._showAddTaskSheet = showAddTaskSheet
        self._newTaskTitle = newTaskTitle
        self._newTaskDeadline = newTaskDeadline
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.completionPercentage = completionPercentage
        self.saveTasks = saveTasks
        self.scheduleTaskNotifications = scheduleTaskNotifications
        self.recommendWorkSchedule = recommendWorkSchedule
        self.timeLeftString = timeLeftString
        self.workStartHour = workStartHour
        self.workEndHour = workEndHour
        
        // Make List background transparent globally
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some View {
        VStack(spacing: 15) {
            Spacer(minLength: 48)

            VStack(spacing: 10) {
                Text("\(Int(completionPercentage)) of 100% done")
                    .font(.title2)
                    .foregroundColor(textColor)

                ProgressView(value: completionPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#007AFF")))
                    .animation(.easeInOut(duration: 0.5), value: completionPercentage)
            }
            .padding(.horizontal)

            List {
                Section(header: Text("Priority").foregroundColor(textColor)) {
                    ForEach($tasks.filter { task in
                        let hoursLeft = Int(task.wrappedValue.deadline.timeIntervalSinceNow / 3600)
                        return task.wrappedValue.priority == .high || (task.wrappedValue.priority == .medium && hoursLeft < 24)
                    }) { $task in
                        taskRowView(task: $task)
                            .listRowBackground(backgroundColor)
                    }
                    .onDelete(perform: deleteTask)
                }
                .listRowBackground(backgroundColor) // Add this for section background

                Section(header: Text("Non-Priority").foregroundColor(textColor)) {
                    ForEach($tasks.filter { task in
                        let hoursLeft = Int(task.wrappedValue.deadline.timeIntervalSinceNow / 3600)
                        return task.wrappedValue.priority == .low || (task.wrappedValue.priority == .medium && hoursLeft >= 24)
                    }) { $task in
                        taskRowView(task: $task)
                            .listRowBackground(backgroundColor)
                    }
                    .onDelete(perform: deleteTask)
                }
                .listRowBackground(backgroundColor) // Add this for section background
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden) // This hides the default List background
            .background(backgroundColor) // Set the List background explicitly

            Button(action: {
                showBreakScreen = true
            }) {
                Text("Take a Break")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#BA8E23"))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .sheet(isPresented: $showBreakScreen) {
                BreakView(isPresented: $showBreakScreen)
            }

            Spacer(minLength: 3)

            HStack {
                Spacer()
                Button(action: { showAddTaskSheet = true }) {
                    Image("addtaskbutton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320, height: 60)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .fullScreenCover(isPresented: $showAddTaskSheet) {
                AddTaskView(
                    newTaskTitle: $newTaskTitle,
                    newTaskDeadline: $newTaskDeadline,
                    onSave: { title, deadline, priority, schedule, groupMembers in
                        let newTask = Task(
                            title: title,
                            deadline: deadline ?? Date().addingTimeInterval(3600),
                            priority: priority,
                            workSchedule: schedule,
                            groupMembers: groupMembers
                        )
                        tasks.append(newTask)
                        saveTasks(tasks)
                        scheduleTaskNotifications(newTask)
                        newTaskTitle = ""
                        newTaskDeadline = nil
                        showAddTaskSheet = false
                    },
                    recommendWorkSchedule: { title, deadline, priority in
                        recommendWorkSchedule(title, deadline, priority, (workStartHour, workEndHour))
                    }
                )
            }
        }
        .background(backgroundColor.ignoresSafeArea())
    }

    private func taskRowView(task: Binding<Task>) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(task.wrappedValue.isCompleted ? "checkbox-checked" : "checkbox-unchecked")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            task.wrappedValue.isCompleted.toggle()
                            saveTasks(tasks)
                        }
                    }

                Text(task.wrappedValue.title + (task.wrappedValue.groupMembers?.isEmpty == false ? " (GT)" : ""))
                    .font(.system(size: 18))
                    .foregroundColor(textColor)
                    .opacity(task.wrappedValue.isCompleted ? 0.5 : 1.0)
                    .strikethrough(task.wrappedValue.isCompleted)

                Spacer()

                Text(timeLeftString(task.wrappedValue.deadline))
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .onTapGesture {
                withAnimation {
                    if expandedTaskIDs.contains(task.wrappedValue.id) {
                        expandedTaskIDs.remove(task.wrappedValue.id)
                    } else {
                        expandedTaskIDs.insert(task.wrappedValue.id)
                    }
                }
            }

            if expandedTaskIDs.contains(task.wrappedValue.id) {
                let workSchedule = recommendWorkSchedule(task.wrappedValue.title, task.wrappedValue.deadline, task.wrappedValue.priority, (workStartHour, workEndHour))
                let completion = task.wrappedValue.isCompleted ? 100 : (workSchedule.isEmpty ? 0 : Double(workSchedule.prefix { $0.startTime < Date() }.count) / Double(workSchedule.count) * 100)

                VStack(alignment: .leading, spacing: 8) {
                    if let groupMembers = task.wrappedValue.groupMembers, !groupMembers.isEmpty {
                        Text("Group Task with: \(groupMembers.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Text("Schedule:")
                        .font(.headline)
                        .foregroundColor(textColor)

                    ForEach(workSchedule.indices, id: \.self) { i in
                        let block = workSchedule[i]
                        Text("Block \(i + 1): \(formatDate(block.startTime)) → \(formatDuration(block.duration))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress: \(Int(completion))%")
                            .font(.caption)
                            .foregroundColor(textColor)
                        ProgressView(value: completion, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#007AFF")))
                    }
                }
                .padding(.top, 6)
            }
        }
        .padding(.vertical, 6)
    }

    private func deleteTask(at offsets: IndexSet) {
        withAnimation {
            tasks.remove(atOffsets: offsets)
            saveTasks(tasks)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remaining = minutes % 60
            return "\(hours) hr \(remaining) min"
        }
    }
}
