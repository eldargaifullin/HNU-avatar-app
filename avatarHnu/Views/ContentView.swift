import SwiftUI

struct ContentView: View {
    @StateObject private var conversation = Conversation()
    @FocusState private var isInputFieldFocused: Bool // To manage keyboard focus for text input
    @State private var isListening: Bool = false

    var body: some View {
        ZStack {
            // Background with HNU logo
            Image("HNU_Logo")
                .resizable()
                .scaledToFit()
                .opacity(0.1)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Display conversation logs
                ScrollView {
                    ForEach(conversation.talkLogs) { log in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.purple)
                                Text(log.question)
                                    .padding()
                                    .background(Color.gray) // Non-transparent background for text
                                    .cornerRadius(10)
                            }
                            HStack {
                                Image(systemName: "server.rack")
                                    .foregroundColor(.green)
                                Text(log.answer)
                                    .padding()
                                    .background(Color.white) // Non-transparent background for text
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Divider()

                // Input area
                HStack(spacing: 16) { // Add spacing between buttons
                    TextField("Type anything here...", text: $conversation.prompt)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .focused($isInputFieldFocused)

                    Button(action: {
                        Task {
                            await conversation.ask(usingTextInput: conversation.prompt)
                            conversation.prompt = "" // Clear input after submission
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 44, height: 44)
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(90))
                        }
                    }

                    // Mic button for start and stop listening
                    ZStack {
                        Circle()
                            .fill(isListening ? Color.red : Color.blue)
                            .frame(width: 44, height: 44)

                        Image(systemName: isListening ? "mic.fill" : "mic")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isListening {
                                    isListening = true
                                    conversation.startListening()
                                }
                            }
                            .onEnded { _ in
                                if isListening {
                                    isListening = false
                                    conversation.stopListening()
                                }
                            }
                    )
                }
                .padding()
            }
            .padding()
        }
        .onTapGesture {
            isInputFieldFocused = false // Dismiss keyboard when tapping outside
        }
        .onAppear {
            print("App Documents Directory: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)")
        }
        .environmentObject(conversation)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

