import SwiftUI

struct ContentView: View {
    @StateObject private var conversation = Conversation()
    @FocusState private var isInputFieldFocused: Bool // To manage keyboard focus for text input

    var body: some View {
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
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.green)
                            Text(log.answer)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Divider()

            // Input area
            HStack {
                TextField("Type your command...", text: $conversation.prompt)
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
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()

            // Voice input controls
            HStack {
                Button("Start Listening") {
                    conversation.startListening()
                }
                .padding()
                .background(Color.green.opacity(0.7))
                .cornerRadius(10)
                .foregroundColor(.white)

                Button("Stop Listening") {
                    conversation.stopListening()
                }
                .padding()
                .background(Color.red.opacity(0.7))
                .cornerRadius(10)
                .foregroundColor(.white)
            }
        }
        .padding()
        .onTapGesture {
            isInputFieldFocused = false // Dismiss keyboard when tapping outside
        }
        .environmentObject(conversation)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

