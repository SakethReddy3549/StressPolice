import SwiftUI
import UserNotifications
import AVKit

struct ContentView: View {
    @Binding var isDarkMode: Bool
    @Binding var isLoggedIn: Bool
    let logoutAction: () -> Void

    @State private var tasks: [Task] = []
    @State private var newTaskTitle = ""
    @State private var isMenuOpen = false
    @State private var selectedView = "Tasks"
    @State private var newTaskDeadline: Date? = nil
    @State private var showAddTaskSheet = false
    @State private var name = UserDefaults.standard.string(forKey: "name") ?? "Sunny"
    @State private var bio = UserDefaults.standard.string(forKey: "bio") ?? "stressing the police"
    @State private var workStartHour = UserDefaults.standard.integer(forKey: "workStartHour")
    @State private var workEndHour = UserDefaults.standard.integer(forKey: "workEndHour")
    @State private var isEditingName = false
    @State private var isEditingBio = false
    @State private var chatMessages: [ChatMessage] = []
    @State private var chatInput = ""
    @State private var showDatePicker = false
    @State private var selectedDate = Date()

    init(isDarkMode: Binding<Bool>, isLoggedIn: Binding<Bool>, logoutAction: @escaping () -> Void) {
        self._isDarkMode = isDarkMode
        self._isLoggedIn = isLoggedIn
        self.logoutAction = logoutAction
    }

    private var backgroundColor: Color {
        isDarkMode ? Color(hex: "#212121") : Color(hex: "#F5F5F5")
    }
    private var textColor: Color {
        isDarkMode ? .white : .black
    }
    private var secondaryBackgroundColor: Color {
        isDarkMode ? Color(hex: "#333333") : Color(hex: "#E0E0E0")
    }
    private var tertiaryBackgroundColor: Color {
        isDarkMode ? Color(hex: "#424242") : Color(hex: "#D1D1D1")
    }

    var completionPercentage: Double {
        let completed = tasks.filter { $0.isCompleted }.count
        return tasks.count > 0 ? Double(completed) / Double(tasks.count) * 100 : 0
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                mainContentView(geometry: geometry)
                    .disabled(isMenuOpen)
                    .blur(radius: isMenuOpen ? 4 : 0)

                if isMenuOpen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { isMenuOpen = false }
                        }
                        .zIndex(1)
                }

                sidebarView()
                    .frame(width: 220)
                    .offset(x: isMenuOpen ? 0 : -240)
                    .animation(.easeInOut(duration: 0.25), value: isMenuOpen)
                    .zIndex(2)

                hamburgerButton
                    .zIndex(3)
            }
            .onAppear {
                loadTasks()
                loadChatMessages()
                configureAudioSession()
            }
        }
    }

    private func mainContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            switch selectedView {
            case "Tasks":
                TasksView(
                    tasks: $tasks,
                    showAddTaskSheet: $showAddTaskSheet,
                    newTaskTitle: $newTaskTitle,
                    newTaskDeadline: $newTaskDeadline,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    completionPercentage: completionPercentage,
                    saveTasks: saveTasks,
                    scheduleTaskNotifications: scheduleTaskNotifications,
                    recommendWorkSchedule: { title, deadline, priority, workHours in
                        recommendWorkSchedule(forTaskTitle: title, deadline: deadline, priority: priority, workHours: workHours)
                    },
                    timeLeftString: timeLeftString,
                    workStartHour: workStartHour,
                    workEndHour: workEndHour
                )

            case "Music":
                MusicView(
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    secondaryBackgroundColor: secondaryBackgroundColor
                )

            case "Chat":
                ReusableChatView(
                    chatMessages: $chatMessages,
                    chatInput: $chatInput,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    secondaryBackgroundColor: secondaryBackgroundColor,
                    tertiaryBackgroundColor: tertiaryBackgroundColor,
                    isDarkMode: isDarkMode,
                    saveChatMessages: saveChatMessages,
                    groupTaskName: tasks.first(where: { $0.groupMembers != nil })?.title
                )
            case "Settings":
                SettingsView(
                    isDarkMode: $isDarkMode,
                    tasks: $tasks,
                    newTaskTitle: $newTaskTitle,
                    newTaskDeadline: $newTaskDeadline,
                    isMenuOpen: $isMenuOpen,
                    selectedView: $selectedView,
                    logoutAction: logoutAction,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    secondaryBackgroundColor: secondaryBackgroundColor
                )
            case "Plans":
                PlansView(
                    tasks: $tasks,
                    showDatePicker: $showDatePicker,
                    selectedDate: $selectedDate,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    saveTasks: saveTasks
                )
            case "Profile":
                ProfileView(
                    name: $name,
                    bio: $bio,
                    isEditingName: $isEditingName,
                    isEditingBio: $isEditingBio,
                    workStartHour: $workStartHour,
                    workEndHour: $workEndHour,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    saveProfile: saveProfile
                )
            default:
                Text("Coming Soon!")
                    .font(.title2)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var hamburgerButton: some View {
        VStack {
            Button(action: {
                withAnimation { isMenuOpen.toggle() }
            }) {
                Image(isDarkMode ? "hamburgerdark" : "hamburgerlight")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .padding(.leading, 20)
            .padding(.top, 40)
            Spacer()
        }
    }

    private func sidebarView() -> some View {
        VStack(alignment: .leading, spacing: 25) {
            Spacer().frame(height: 50)
            menuItem(icon: "music", title: "Music", selection: "Music") // uses music.png in Assets
            menuItem(icon: "chatbutton", title: "Chat", selection: "Chat")
            menuItem(icon: isDarkMode ? "profiledark" : "profilelight", title: "Profile", selection: "Profile")
            menuItem(icon: isDarkMode ? "setting-icon-dark" : "setting-icon-white", title: "Settings", selection: "Settings")
            Divider().background(Color(hex: "#424242"))
            menuItem(icon: "checkbox-unchecked", title: "Tasks", selection: "Tasks")
            menuItem(icon: "checkbox-checked", title: "Plans", selection: "Plans")
            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .background(backgroundColor)
    }

    private func menuItem(icon: String, title: String, selection: String) -> some View {
        Button(action: {
            selectedView = selection
            withAnimation { isMenuOpen = false }
        }) {
            HStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(selectedView == selection ? Color(hex: "#007AFF") : textColor)
            }
        }
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Task Persistence & Helpers

    private func scheduleTaskNotifications(for task: Task) {
        let center = UNUserNotificationCenter.current()
        let intervals: [TimeInterval] = [86400, 3600, 900]
        let messages = [
            "Yo, \(task.title) is 24 hours away! Let’s crush it! 💪",
            "1 hour to go for \(task.title). You're almost there!",
            "15 minutes left for \(task.title). Hustle time! 🚀"
        ]

        for (index, interval) in intervals.enumerated() {
            let triggerDate = task.deadline.addingTimeInterval(-interval)
            let timeRemaining = triggerDate.timeIntervalSince(Date())
            guard timeRemaining > 0 else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Task Reminder"
            content.body = messages[index]
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
            let request = UNNotificationRequest(identifier: "\(task.id.uuidString)-\(index)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    private func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let savedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            self.tasks = savedTasks
        }
    }

    private func saveChatMessages() {
        if let encoded = try? JSONEncoder().encode(chatMessages) {
            UserDefaults.standard.set(encoded, forKey: "chatMessages")
        }
    }

    private func loadChatMessages() {
        if let data = UserDefaults.standard.data(forKey: "chatMessages"),
           let saved = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            self.chatMessages = saved
        }
    }

    private func saveProfile(_ name: String, _ bio: String, _ workStartHour: Int, _ workEndHour: Int) {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(bio, forKey: "bio")
        UserDefaults.standard.set(workStartHour, forKey: "workStartHour")
        UserDefaults.standard.set(workEndHour, forKey: "workEndHour")
    }
}
