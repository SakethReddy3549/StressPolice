import SwiftUI
import Combine

struct ReusableChatView: View {
    @Binding var chatMessages: [ChatMessage]
    @Binding var chatInput: String
    let textColor: Color
    let backgroundColor: Color
    let secondaryBackgroundColor: Color
    let tertiaryBackgroundColor: Color
    let isDarkMode: Bool
    let saveChatMessages: () -> Void
    let groupTaskName: String?

    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var showFriendsSheet = false
    @State private var friends: [String] = ["Anthony", "Sanjana"]
    @State private var friendCodeInput: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    chatHeader
                    chatMessagesSection(geometry: geometry)
                    inputField(safeAreaBottom: geometry.safeAreaInsets.bottom)
                }
                .padding(.bottom, keyboardHeight)
                .onReceive(Publishers.keyboardHeight) { height in
                    keyboardHeight = height
                }
                .onAppear {
                    if chatMessages.isEmpty {
                        preloadDemoMessages()
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showFriendsSheet) {
            friendsSheet
        }
    }

    private var chatHeader: some View {
        HStack {
            Text(groupTaskName ?? "Group Chat")
                .font(.headline)
                .foregroundColor(textColor)
            Spacer()
            Button(action: {
                withAnimation {
                    showFriendsSheet.toggle()
                }
            }) {
                Image(isDarkMode ? "friendsdark" : "friendslight")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(8)
                    .background(tertiaryBackgroundColor.opacity(0.8))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private func chatMessagesSection(geometry: GeometryProxy) -> some View {
        ScrollViewReader { proxy in
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
                        .id(message.id)
                    }
                }
                .padding(.horizontal)
                .onChange(of: chatMessages.count) {
                    scrollToBottom(proxy)
                }
            }
        }
    }

    private func inputField(safeAreaBottom: CGFloat) -> some View {
        HStack(spacing: 10) {
            TextField("Type a message", text: $chatInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(textColor)
                .submitLabel(.send)
                .focused($isTextFieldFocused)
                .onSubmit(sendMessage)
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, safeAreaBottom + 4)
        .background(backgroundColor.ignoresSafeArea(edges: .bottom))
    }

    private var friendsSheet: some View {
        VStack(spacing: 20) {
            Text("Friends")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(textColor)
                .padding(.top, 20)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(friends, id: \.self) { friend in
                        HStack {
                            Text(friend)
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(textColor)
                                .padding(.vertical, 10)
                                .padding(.leading, 16)

                            Spacer()

                            Button(action: {
                                withAnimation {
                                    if let index = friends.firstIndex(of: friend) {
                                        friends.remove(at: index)
                                    }
                                }
                            }) {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        .background(secondaryBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
            }

            VStack(spacing: 12) {
                Text("Add Friend")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(textColor.opacity(0.8))

                TextField("Enter Friend Code", text: $friendCodeInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(textColor)
                    .padding(12)
                    .background(tertiaryBackgroundColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .submitLabel(.done)

                Button(action: {
                    if !friendCodeInput.isEmpty {
                        withAnimation {
                            friends.append(friendCodeInput)
                            friendCodeInput = ""
                        }
                    }
                }) {
                    Text("Add")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#007AFF"))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func sendMessage() {
        guard !chatInput.isEmpty else { return }
        chatMessages.append(ChatMessage(name: "You", message: chatInput))
        chatInput = ""
        saveChatMessages()
    }

    private func preloadDemoMessages() {
        chatMessages = [
            ChatMessage(name: "Anthony", message: "Yo this Stress Police app is turning out pretty sick."),
            ChatMessage(name: "Sanjana", message: "Yeah! Especially with how we integrated the planner and the music features."),
            ChatMessage(name: "You", message: "Don’t forget the ‘Take a Break’ animation page. Looks super clean."),
            ChatMessage(name: "Anthony", message: "Bro that Figma design really helped us stay focused."),
            ChatMessage(name: "Sanjana", message: "And the sidebar layout feels natural. Feels native."),
            ChatMessage(name: "You", message: "For the HCI presentation, let’s lead with the stress problem + solution."),
            ChatMessage(name: "Anthony", message: "And demo how the planner and task reminders sync with user schedule."),
            ChatMessage(name: "Sanjana", message: "Also show the offline login! That’s a win."),
            ChatMessage(name: "You", message: "Let’s keep it light and visual. Anthony you take the flow, I’ll show the UI."),
            ChatMessage(name: "Anthony", message: "Bet. Sanjana you close it with benefits and feedback points?")
        ]
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let last = chatMessages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}
