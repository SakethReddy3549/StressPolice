import UserNotifications
import SwiftUI

// Task model
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var deadline: Date
    var priority: Priority
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    init(title: String, isCompleted: Bool = false, deadline: Date = Date().addingTimeInterval(3600), priority: Priority = .medium) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.deadline = deadline
        self.priority = priority
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, deadline, priority
    }
}

struct ChatMessage: Identifiable, Codable {
    var id: UUID
    let name: String
    let message: String
    
    init(name: String, message: String) {
        self.id = UUID()
        self.name = name
        self.message = message
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, message
    }
}

struct Plan: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var dueDate: Date
    var priority: String
}

// Root view to manage login/signup flow
struct RootView: View {
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var showLogin = false
    @State private var showSignup = false
    @State private var isDarkMode = true
    
    private var backgroundColor: Color {
        isDarkMode ? Color("#212121") : Color("#F5F5F5")
    }
    private var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                if !isLoggedIn {
                    Text("Stress Police")
                        .font(.custom("Avenir", size: 36))
                        .foregroundColor(textColor)
                        .position(x: geometry.size.width / 2, y: 100)
                        .zIndex(2)
                }
                
                if isLoggedIn {
                    ContentView(isDarkMode: $isDarkMode, isLoggedIn: $isLoggedIn, logoutAction: {
                        isLoggedIn = false
                        showLogin = false
                        showSignup = false
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    })
                } else if showLogin {
                    LoginView(isLoggedIn: $isLoggedIn, isDarkMode: $isDarkMode)
                } else if showSignup {
                    SignupView(showLogin: $showLogin, isDarkMode: $isDarkMode)
                } else {
                    VStack(spacing: 40) {
                        Spacer()
                        VStack(spacing: 10) {
                            Text("Existing user?")
                                .font(.system(size: 16))
                                .foregroundColor(textColor)
                            Button(action: { showLogin = true }) {
                                Text("Login")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color("#4CAF50"))
                                    .cornerRadius(8)
                            }
                        }
                        VStack(spacing: 10) {
                            Text("New user?")
                                .font(.system(size: 16))
                                .foregroundColor(textColor)
                            Button(action: { showSignup = true }) {
                                Text("Signup")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color("#F44336"))
                                    .cornerRadius(8)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// Login View
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var isDarkMode: Bool
    @State private var emailPhone = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var keyboardHeight: CGFloat = 0
    
    private var backgroundColor: Color {
        isDarkMode ? Color("#212121") : Color("#F5F5F5")
    }
    private var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 150)
                TextField("Email/Phone", text: $emailPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(textColor)
                    .padding(.horizontal)
                    .submitLabel(.done)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(textColor)
                    .padding(.horizontal)
                    .submitLabel(.done)
                Button(action: {
                    if isValidEmail(emailPhone) {
                        isLoggedIn = true
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    } else {
                        showAlert = true
                    }
                }) {
                    Text("Login")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color("#007AFF"))
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
        }
        .background(backgroundColor)
        .ignoresSafeArea(.keyboard, edges: .bottom) // Key fix
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Email"),
                message: Text("Enter a valid Email"),
                dismissButton: .default(Text("OK")) { showAlert = false }
            )
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

// Signup View
struct SignupView: View {
    @Binding var showLogin: Bool
    @Binding var isDarkMode: Bool
    @State private var emailPhone = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var keyboardHeight: CGFloat = 0
    
    private var backgroundColor: Color {
        isDarkMode ? Color("#212121") : Color("#F5F5F5")
    }
    private var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 150)
                TextField("Email/Phone", text: $emailPhone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(textColor)
                    .padding(.horizontal)
                    .submitLabel(.done)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(textColor)
                    .padding(.horizontal)
                    .submitLabel(.done)
                Button(action: {
                    if isValidEmail(emailPhone) {
                        showLogin = true
                    } else {
                        showAlert = true
                    }
                }) {
                    Text("Signup")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color("#007AFF"))
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
        }
        .background(backgroundColor)
        .ignoresSafeArea(.keyboard, edges: .bottom) // Key fix
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Email"),
                message: Text("Enter a valid Email"),
                dismissButton: .default(Text("OK")) { showAlert = false }
            )
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
}

// Subviews for ContentView sections
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
    
    var timeLeftString: (Date) -> String
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
                .frame(height: 80)
            VStack(spacing: 10) {
                Text("\(Int(completionPercentage)) of 100% done")
                    .font(.title2)
                    .foregroundColor(textColor)
                ProgressView(value: completionPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("#007AFF")))
                    .animation(.easeInOut(duration: 0.5), value: completionPercentage)
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Priority")
                        .font(.title3)
                        .foregroundColor(textColor)
                        .padding(.horizontal)

                    ForEach($tasks.filter { task in
                        let hoursLeft = Int(task.deadline.wrappedValue.timeIntervalSince(Date()) / 3600)
                        return task.priority.wrappedValue == .high || (task.priority.wrappedValue == .medium && hoursLeft < 24)
                    }) { $task in
                        HStack {
                            Image(task.isCompleted ? "checkbox-checked" : "checkbox-unchecked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .onTapGesture { withAnimation(.easeInOut(duration: 0.5)) { task.isCompleted.toggle() } }
                            Text(task.title)
                                .font(.system(size: 18))
                                .foregroundColor(textColor)
                                .opacity(task.isCompleted ? 0.5 : 1.0)
                                .strikethrough(task.isCompleted)
                                .animation(.easeInOut(duration: 0.5), value: task.isCompleted)
                            Spacer()
                            Text(timeLeftString(task.deadline))
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .contextMenu { // Replace swipeActions with contextMenu
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

                    Text("Non-Priority")
                        .font(.title3)
                        .foregroundColor(textColor)
                        .padding(.horizontal)

                    ForEach($tasks.filter { task in
                        let hoursLeft = Int(task.deadline.wrappedValue.timeIntervalSince(Date()) / 3600)
                        return task.priority.wrappedValue == .low || (task.priority.wrappedValue == .medium && hoursLeft >= 24)
                    }) { $task in
                        HStack {
                            Image(task.isCompleted ? "checkbox-checked" : "checkbox-unchecked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .onTapGesture { withAnimation(.easeInOut(duration: 0.5)) { task.isCompleted.toggle() } }
                            Text(task.title)
                                .font(.system(size: 18))
                                .foregroundColor(textColor)
                                .opacity(task.isCompleted ? 0.5 : 1.0)
                                .strikethrough(task.isCompleted)
                                .animation(.easeInOut(duration: 0.5), value: task.isCompleted)
                            Spacer()
                            Text(timeLeftString(task.deadline))
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .contextMenu { // Replace swipeActions with contextMenu
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
            .frame(maxHeight: .infinity)
            
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
            .padding(.bottom, 40)
            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(newTaskTitle: $newTaskTitle, newTaskDeadline: $newTaskDeadline, onSave: { title, deadline, priority in
                    let newTask = Task(title: title, deadline: deadline ?? Date().addingTimeInterval(3600), priority: priority)
                    tasks.append(newTask)
                    saveTasks(tasks)
                    scheduleTaskNotifications(newTask)
                    newTaskTitle = ""
                    newTaskDeadline = nil
                    showAddTaskSheet = false
                })
                .presentationDetents([.medium])
            }
        }
        .frame(maxHeight: .infinity)
        .background(backgroundColor)
    }
}

struct ChatView: View {
    @Binding var chatMessages: [ChatMessage]
    @Binding var chatInput: String
    let textColor: Color
    let backgroundColor: Color
    let secondaryBackgroundColor: Color
    let tertiaryBackgroundColor: Color
    let isDarkMode: Bool
    let saveChatMessages: () -> Void
    
    @State private var friends = ["Anthony", "Sanjana"]
    @State private var friendCodeInput = ""
    @State private var showFriendsList = false
    @State private var showAddFriendField = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Button(action: { showFriendsList.toggle() }) {
                        Image(isDarkMode ? "friendsdark" : "friendslight")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    if showFriendsList {
                        Button(action: { showAddFriendField.toggle() }) {
                            Image("plussmall")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 10)
            
            if showFriendsList {
                if showAddFriendField {
                    VStack(spacing: 20) {
                        Text("Add Friend")
                            .font(.title2)
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        TextField("Enter friend #", text: $friendCodeInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(textColor)
                            .padding(.horizontal, 20)
                            .submitLabel(.done)
                        
                        Button(action: {
                            if !friendCodeInput.isEmpty {
                                friends.append(friendCodeInput)
                                friendCodeInput = ""
                                showAddFriendField = false
                            }
                        }) {
                            Text("Send Request")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 150)
                                .background(Color("#007AFF"))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 20) {
                        Text("Friends")
                            .font(.title2)
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(friends, id: \.self) { friend in
                                    HStack(spacing: 20) {
                                        Text(friend)
                                            .font(.system(size: 18))
                                            .foregroundColor(textColor)
                                        Spacer()
                                        Button(action: {
                                            if let index = friends.firstIndex(of: friend) {
                                                friends.remove(at: index)
                                            }
                                        }) {
                                            Image(isDarkMode ? "trashdark" : "trashlight")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(chatMessages) { message in
                            HStack(spacing: 8) {
                                Text(message.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(textColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(tertiaryBackgroundColor)
                                    .cornerRadius(12)
                                Text(message.message)
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                                    .padding(10)
                                    .background(secondaryBackgroundColor)
                                    .cornerRadius(12)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            
            if !showFriendsList {
                HStack(spacing: 10) {
                    Button(action: {}) {
                        Image("imageicon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    Button(action: {}) {
                        Image("voiceicon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    TextField("Type a message", text: $chatInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(textColor)
                        .submitLabel(.send)
                        .onSubmit {
                            if !chatInput.isEmpty {
                                chatMessages.append(ChatMessage(name: "Sunny", message: chatInput))
                                chatInput = ""
                                saveChatMessages()
                            }
                        }
                    Button(action: {
                        if !chatInput.isEmpty {
                            chatMessages.append(ChatMessage(name: "Sunny", message: chatInput))
                            chatInput = ""
                            saveChatMessages()
                        }
                    }) {
                        Image("sendbutton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .frame(maxHeight: .infinity)
        .background(backgroundColor)
        .ignoresSafeArea(.keyboard, edges: .bottom) // Key fix
    }
}

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Binding var tasks: [Task]
    @Binding var newTaskTitle: String
    @Binding var newTaskDeadline: Date?
    @Binding var isMenuOpen: Bool
    @Binding var selectedView: String
    let logoutAction: () -> Void
    let textColor: Color
    let backgroundColor: Color
    let secondaryBackgroundColor: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 40)
            Text("Settings")
                .font(.title2)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)

            Button(action: {
                isDarkMode.toggle()
            }) {
                HStack {
                    Text("Theme")
                        .font(.system(size: 18))
                        .foregroundColor(textColor)
                    Spacer()
                    Text(isDarkMode ? "Dark" : "Light")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(secondaryBackgroundColor)
                .cornerRadius(8)
            }
            .padding(.horizontal)

            Button(action: {
                tasks = []
                newTaskTitle = ""
                newTaskDeadline = nil
                isMenuOpen = false
                selectedView = "Tasks"
            }) {
                Text("Reset")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Button(action: {
                logoutAction()
                isMenuOpen = false
            }) {
                Text("Logout")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 10)
        .padding(.bottom, 40)
        .frame(maxHeight: .infinity)
        .background(backgroundColor)
    }
}

struct PlansView: View {
    @Binding var tasks: [Task]
    @Binding var showDatePicker: Bool
    @Binding var selectedDate: Date
    let textColor: Color
    let backgroundColor: Color
    let saveTasks: ([Task]) -> Void // Add this parameter
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    func formatDueTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)
            Button(action: { showDatePicker = true }) {
                Text("Select Date")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("#007AFF"))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .background(backgroundColor)
            .zIndex(1)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    let today = Calendar.current.startOfDay(for: Date())
                    let todayTasks = tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: today) }
                    let todayCompletion = todayTasks.isEmpty ? 0 : Double(todayTasks.filter { $0.isCompleted }.count) / Double(todayTasks.count) * 100
                    Text("Today, \(dateFormatter.string(from: today))")
                        .font(.title3)
                        .foregroundColor(textColor)
                        .padding(.horizontal, 20)
                    VStack(spacing: 10) {
                        Text("\(Int(todayCompletion)) of 100% done")
                            .font(.title2)
                            .foregroundColor(textColor)
                        ProgressView(value: todayCompletion, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color("#007AFF")))
                    }
                    .padding(.horizontal, 20)
                    ForEach(tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: today) }, id: \.id) { task in
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
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .contextMenu { // Replace swipeActions with contextMenu
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
                    
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                    let tomorrowTasks = tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: tomorrow) }
                    let tomorrowCompletion = tomorrowTasks.isEmpty ? 0 : Double(tomorrowTasks.filter { $0.isCompleted }.count) / Double(tomorrowTasks.count) * 100
                    Text("Tomorrow, \(dateFormatter.string(from: tomorrow))")
                        .font(.title3)
                        .foregroundColor(textColor)
                        .padding(.horizontal, 20)
                    VStack(spacing: 10) {
                        Text("\(Int(tomorrowCompletion)) of 100% done")
                            .font(.title2)
                            .foregroundColor(textColor)
                        ProgressView(value: tomorrowCompletion, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color("#007AFF")))
                    }
                    .padding(.horizontal, 20)
                    ForEach(tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: tomorrow) }, id: \.id) { task in
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
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .contextMenu {
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
                    
                    if !Calendar.current.isDate(selectedDate, inSameDayAs: today) && !Calendar.current.isDate(selectedDate, inSameDayAs: tomorrow) {
                        let selectedTasks = tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: selectedDate) }
                        let selectedCompletion = selectedTasks.isEmpty ? 0 : Double(selectedTasks.filter { $0.isCompleted }.count) / Double(selectedTasks.count) * 100
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.title3)
                            .foregroundColor(textColor)
                            .padding(.horizontal, 20)
                        VStack(spacing: 10) {
                            Text("\(Int(selectedCompletion)) of 100% done")
                                .font(.title2)
                                .foregroundColor(textColor)
                            ProgressView(value: selectedCompletion, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color("#007AFF")))
                        }
                        .padding(.horizontal, 20)
                        ForEach(tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: selectedDate) }, id: \.id) { task in
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
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .contextMenu {
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
                .padding(.bottom, 20)
            }
            .frame(maxHeight: .infinity)
            .background(backgroundColor)
            .sheet(isPresented: $showDatePicker) {
                VStack(spacing: 20) {
                    DatePicker("Select a Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                    Button("Done") {
                        showDatePicker = false
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Color("#007AFF"))
                }
                .padding()
                .background(backgroundColor)
            }
        }
    }
}

struct ProfileView: View {
    @Binding var name: String
    @Binding var bio: String
    @Binding var isEditingName: Bool
    @Binding var isEditingBio: Bool
    let textColor: Color
    let backgroundColor: Color
    let saveProfile: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
                .frame(height: 60)
            
            Text("Profile")
                .font(.title2)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 20) {
                    if isEditingName {
                        TextField("Name", text: $name)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(textColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                isEditingName = false
                                saveProfile(name, bio)
                            }
                    } else {
                        Text("Name: \(name)")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(textColor)
                    }
                    Spacer()
                    Button(action: { isEditingName.toggle() }) {
                        Text("Edit")
                            .font(.system(size: 16))
                            .foregroundColor(Color("#007AFF"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                
                HStack(spacing: 20) {
                    if isEditingBio {
                        TextField("Bio", text: $bio)
                            .font(.system(size: 18))
                            .foregroundColor(textColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                isEditingBio = false
                                saveProfile(name, bio)
                            }
                    } else {
                        Text("Bio: \(bio)")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: { isEditingBio.toggle() }) {
                        Text("Edit")
                            .font(.system(size: 16))
                            .foregroundColor(Color("#007AFF"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                
                Text("Email: nicetrydude@gmail.com")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(backgroundColor)
    }
}

// Main App Content
struct ContentView: View {
    @Binding var isDarkMode: Bool
    @Binding var isLoggedIn: Bool
    let logoutAction: () -> Void
    @State private var tasks: [Task] = {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let savedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            return savedTasks
        }
        return [
            Task(title: "Meditate", isCompleted: false, deadline: Date().addingTimeInterval(1800), priority: .high),
            Task(title: "Drink water", isCompleted: true, deadline: Date().addingTimeInterval(7200), priority: .low),
            Task(title: "Exercise", isCompleted: true, deadline: Date().addingTimeInterval(9000), priority: .high)
        ]
    }()
    @State private var newTaskTitle = ""
    @State private var isMenuOpen = false
    @State private var selectedView = "Tasks"
    @State private var showingNewTaskInput = false
    @State private var newTaskDeadline: Date? = nil
    @State private var showAddTaskSheet = false
    @State private var name: String = UserDefaults.standard.string(forKey: "name") ?? "Sunny"
    @State private var bio: String = UserDefaults.standard.string(forKey: "bio") ?? "stressing the police"
    @State private var isEditingName = false
    @State private var isEditingBio = false
    @State private var chatMessages: [ChatMessage] = {
        if let data = UserDefaults.standard.data(forKey: "chatMessages"),
           let savedMessages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            return savedMessages
        }
        return [
            ChatMessage(name: "Sunny", message: "Hey team, how’s everyone doing on their tasks?"),
            ChatMessage(name: "Anthony", message: "Hey Sunny! I finished \"Drink water\" – feeling hydrated now 💧"),
            ChatMessage(name: "Sanjana", message: "Nice one, Anthony! I’m halfway through \"Exercise\" – gym sesh later. You?"),
            ChatMessage(name: "Sunny", message: "Just checked off \"Meditate\" – 10 mins of calm. Need updates by EOD!"),
            ChatMessage(name: "Anthony", message: "Will do! Btw, anyone else finding these tasks oddly satisfying?"),
            ChatMessage(name: "Sanjana", message: "Totally. Checking boxes is my new therapy 😂"),
            ChatMessage(name: "Sunny", message: "Same! Let’s keep the momentum—updates in an hour?")
        ]
    }()
    @State private var chatInput = ""
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    init(isDarkMode: Binding<Bool>, isLoggedIn: Binding<Bool>, logoutAction: @escaping () -> Void) {
        self._isDarkMode = isDarkMode
        self._isLoggedIn = isLoggedIn
        self.logoutAction = logoutAction
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private var backgroundColor: Color {
        isDarkMode ? Color("#212121") : Color("#F5F5F5")
    }
    private var textColor: Color {
        isDarkMode ? .white : .black
    }
    private var secondaryBackgroundColor: Color {
        isDarkMode ? Color("#333333") : Color("#E0E0E0")
    }
    private var tertiaryBackgroundColor: Color {
        isDarkMode ? Color("#424242") : Color("#D1D1D1")
    }
    
    var completionPercentage: Double {
        let completed = tasks.filter { $0.isCompleted }.count
        return tasks.count > 0 ? Double(completed) / Double(tasks.count) * 100 : 0
    }
    
    func timeLeftString(for deadline: Date) -> String {
        let timeInterval = deadline.timeIntervalSince(Date())
        let minutesLeft = Int(timeInterval / 60)
        let hoursLeft = minutesLeft / 60
        let daysLeft = hoursLeft / 24
        
        if timeInterval <= 0 { // Check if time is up or past due
            return "Time Up"
        } else if minutesLeft <= 60 {
            return "\(minutesLeft) mins left"
        } else if minutesLeft <= 120 {
            return "\(minutesLeft) mins left"
        } else if hoursLeft < 24 {
            return "\(hoursLeft) hours left"
        } else if hoursLeft <= 48 {
            return "\(hoursLeft) hours left"
        } else {
            return "\(daysLeft) days left"
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()

    func formatDueTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                mainContentView(geometry: geometry)
                sidebarOverlayView(geometry: geometry)
                hamburgerButtonView(geometry: geometry)
            }
        }
    }

    private func mainContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)
            
            if selectedView == "Tasks" {
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
                    timeLeftString: timeLeftString
                )
            } else if selectedView == "Chat" {
                ChatView(
                    chatMessages: $chatMessages,
                    chatInput: $chatInput,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    secondaryBackgroundColor: secondaryBackgroundColor,
                    tertiaryBackgroundColor: tertiaryBackgroundColor,
                    isDarkMode: isDarkMode,
                    saveChatMessages: saveChatMessages
                )
            } else if selectedView == "Settings" {
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
            } else if selectedView == "Plans" {
                PlansView(
                    tasks: $tasks,
                    showDatePicker: $showDatePicker,
                    selectedDate: $selectedDate,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    saveTasks: saveTasks // Pass the function
                )
            } else if selectedView == "Profile" {
                ProfileView(
                    name: $name,
                    bio: $bio,
                    isEditingName: $isEditingName,
                    isEditingBio: $isEditingBio,
                    textColor: textColor,
                    backgroundColor: backgroundColor,
                    saveProfile: saveProfile
                )
            } else {
                Text("\(selectedView) Coming Soon!")
                    .font(.title2)
                    .foregroundColor(textColor)
                    .frame(maxHeight: .infinity)
            }
        }
        .background(backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private func sidebarOverlayView(geometry: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(isMenuOpen ? 0.5 : 0))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { withAnimation(.easeInOut(duration: 0.3)) { isMenuOpen = false } }
                .zIndex(0)

            Rectangle()
                .fill(backgroundColor)
                .frame(width: 150)
                .frame(maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack(alignment: .leading, spacing: 25) {
                        Spacer()
                            .frame(height: 50)
                        menuItem(icon: "chatbutton", title: "Chat", selection: "Chat", selectedView: $selectedView, isMenuOpen: $isMenuOpen, textColor: textColor)
                        menuItem(icon: isDarkMode ? "profiledark" : "profilelight", title: "Profile", selection: "Profile", selectedView: $selectedView, isMenuOpen: $isMenuOpen, textColor: textColor)
                        Button(action: {
                            $selectedView.wrappedValue = "Settings"
                            withAnimation(.easeInOut(duration: 0.3)) { $isMenuOpen.wrappedValue = false }
                        }) {
                            HStack(spacing: 4) {
                                Image(isDarkMode ? "setting-icon-dark" : "setting-icon-white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.leading, 2)
                                Text("Settings")
                                    .font(.system(size: 18))
                                    .foregroundColor($selectedView.wrappedValue == "Settings" ? Color("#007AFF") : textColor)
                            }
                        }
                        Divider().frame(height: 1).background(Color("#424242"))
                        menuItem(icon: "checkbox-unchecked", title: "Tasks", selection: "Tasks", selectedView: $selectedView, isMenuOpen: $isMenuOpen, textColor: textColor)
                        menuItem(icon: "checkbox-checked", title: "Plans", selection: "Plans", selectedView: $selectedView, isMenuOpen: $isMenuOpen, textColor: textColor)
                        Spacer()
                    }
                    .padding(.vertical, 20)
                )
                .position(x: isMenuOpen ? 75 : -75, y: geometry.size.height / 2)
                .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
                .zIndex(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func hamburgerButtonView(geometry: GeometryProxy) -> some View {
        VStack {
            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isMenuOpen.toggle() } }) {
                Image(isDarkMode ? "hamburgerdark" : "hamburgerlight")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .padding(.leading, 20)
            .padding(.top, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .zIndex(2)
    }
    
    private func scheduleTaskNotifications(for task: Task) {
        let center = UNUserNotificationCenter.current()
        
        let intervals: [TimeInterval] = [24 * 60 * 60, 60 * 60, 15 * 60]
        let messages = [
            "Yo, \(task.title) is 24 hours away! Time to get pumped—let’s crush it! 💪",
            "Heads up! \(task.title) is due in 1 hour. You’ve got this—go be a rockstar! 🌟",
            "Tick-tock! \(task.title) is 15 mins away. Hustle time—let’s make it epic! 🚀"
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
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    private func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    private func saveChatMessages() {
        if let encoded = try? JSONEncoder().encode(chatMessages) {
            UserDefaults.standard.set(encoded, forKey: "chatMessages")
        }
    }

    private func saveProfile(_ name: String, _ bio: String) {
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(bio, forKey: "bio")
    }
}

extension Color {
    init(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

func menuItem(icon: String, title: String, selection: String, selectedView: Binding<String>, isMenuOpen: Binding<Bool>, textColor: Color, iconSize: CGFloat = 24) -> some View {
    Button(action: {
        selectedView.wrappedValue = selection
        withAnimation(.easeInOut(duration: 0.3)) { isMenuOpen.wrappedValue = false }
    }) {
        HStack(alignment: .center, spacing: 10) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .padding(.leading, 5)
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(selection == selectedView.wrappedValue ? Color("#007AFF") : textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AddTaskView: View {
    @Binding var newTaskTitle: String
    @Binding var newTaskDeadline: Date?
    let onSave: (String, Date?, Task.Priority) -> Void
    @State private var showDatePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var selectedPriority: Task.Priority = .medium
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Add New Task")
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                TextField("Task title", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.horizontal)
                    .submitLabel(.done)
                
                if showDatePicker {
                    DatePicker("Deadline", selection: Binding(
                        get: { newTaskDeadline ?? Date() },
                        set: { newTaskDeadline = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .accentColor(Color("#007AFF"))
                    .padding(.horizontal)
                }
                
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(Task.Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Button(action: { showDatePicker.toggle() }) {
                    Text(showDatePicker ? "Remove Deadline" : "Add Deadline")
                        .foregroundColor(Color("#007AFF"))
                        .padding()
                }
                
                Button(action: {
                    if newTaskTitle.isEmpty {
                        alertMessage = "Please enter a task title"
                        showAlert = true
                    } else if newTaskDeadline == nil {
                        alertMessage = "Please enter the due date and time"
                        showAlert = true
                    } else {
                        onSave(newTaskTitle, newTaskDeadline, selectedPriority)
                    }
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(newTaskDeadline == nil ? Color.gray : Color("#007AFF"))
                        .cornerRadius(8)
                }
                .disabled(newTaskDeadline == nil)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color("#212121") : Color("#F5F5F5"))
        .ignoresSafeArea(.keyboard, edges: .bottom) // Key fix
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) { showAlert = false }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}
