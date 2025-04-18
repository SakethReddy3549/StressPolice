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

    @State private var showTutorial = UserDefaults.standard.bool(forKey: "isFirstLogin")
    @State private var expandedTaskIDs: Set<UUID> = []
    @State private var showBreakScreen = false

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
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(backgroundColor)
                
                Button(action: { showBreakScreen = true }) {
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
                            print("Saving task with workSchedule:", schedule)
                            
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
                        withAnimation {
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
                VStack(alignment: .leading, spacing: 8) {
                    if let groupMembers = task.wrappedValue.groupMembers, !groupMembers.isEmpty {
                        Text("Group Task with: \(groupMembers.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if let blocks = task.wrappedValue.workSchedule, !blocks.isEmpty {
                        Text("Work Plan:")
                            .font(.headline)
                            .foregroundColor(textColor)

                        if blocks.isEmpty {
                            Text("❌ Work schedule is empty")
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        ForEach(blocks) { block in
                            HStack(alignment: .top, spacing: 8) {
                                Image(block.isCompleted ? "checkbox-checked" : "checkbox-unchecked")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .onTapGesture {
                                        tasks = tasks.map { t in
                                            if t.id == task.wrappedValue.id {
                                                var updated = t
                                                if let idx = updated.workSchedule?.firstIndex(where: { $0.id == block.id }) {
                                                    updated.workSchedule?[idx].isCompleted.toggle()
                                                }
                                                return updated
                                            }
                                            return t
                                        }
                                        saveTasks(tasks)
                                    }

                                VStack(alignment: .leading) {
                                    Text("\(formatDate(block.startTime)) → \(formatDuration(block.duration))")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    if let label = block.label {
                                        Text("→ \(label)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }


                        VStack(alignment: .leading, spacing: 4) {
                            let total = blocks.count
                            let completed = blocks.filter { $0.isCompleted }.count
                            let progress = total == 0 ? 0 : Double(completed) / Double(total) * 100

                            Text("Progress: \(Int(progress))%")
                                .font(.caption)
                                .foregroundColor(textColor)

                            ProgressView(value: progress, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#007AFF")))
                        }
                    }
                }
                .padding(.top, 6)
            }
        }
        .padding(.vertical, 6)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(round(duration / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }


    private func deleteTask(at offsets: IndexSet) {
        withAnimation {
            tasks.remove(atOffsets: offsets)
            saveTasks(tasks)
        }
    }
}
