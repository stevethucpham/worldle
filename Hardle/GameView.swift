import SwiftUI

struct GameView: View {
    @StateObject private var gameModel = GameModel()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            // Game title
            Text("HARDLE")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            // Game grid
            VStack(spacing: 8) {
                ForEach(0..<gameModel.maxAttempts, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<gameModel.wordLength, id: \.self) { column in
                            LetterCell(
                                letter: gameModel.guesses[row][column],
                                status: gameModel.getLetterStatus(row: row, column: column)
                            )
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            // Keyboard
            VStack(spacing: 8) {
                // First row: Q-P
                HStack(spacing: 4) {
                    ForEach("QWERTYUIOP".map { $0 }, id: \.self) { char in
                        KeyboardKey(char: char, status: gameModel.keyboardStatus[char] ?? .unused) {
                            gameModel.addLetter(char)
                        }
                    }
                }
                
                // Second row: A-L
                HStack(spacing: 4) {
                    ForEach("ASDFGHJKL".map { $0 }, id: \.self) { char in
                        KeyboardKey(char: char, status: gameModel.keyboardStatus[char] ?? .unused) {
                            gameModel.addLetter(char)
                        }
                    }
                }
                
                // Third row: Enter, Z-M, Backspace
                HStack(spacing: 4) {
                    // Enter key
                    Button {
                        gameModel.submitGuess { success in
                            if !success {
                                alertMessage = "Not a valid word"
                                showAlert = true
                            } else if gameModel.isGameOver() {
                                if gameModel.currentAttempt > 0 {
                                    let lastGuess = String(gameModel.guesses[gameModel.currentAttempt - 1].compactMap { $0 })
                                    if lastGuess == gameModel.targetWord {
                                        alertMessage = "Congratulations! You guessed the word!"
                                    } else {
                                        alertMessage = "Game over! The word was \(gameModel.targetWord)"
                                    }
                                    showAlert = true
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .frame(width: 40, height: 50)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                    }
                    
                    // Middle row keys
                    ForEach("ZXCVBNM".map { $0 }, id: \.self) { char in
                        KeyboardKey(char: char, status: gameModel.keyboardStatus[char] ?? .unused) {
                            gameModel.addLetter(char)
                        }
                    }
                    
                    // Backspace key
                    Button {
                        gameModel.removeLetter()
                    } label: {
                        Image(systemName: "delete.left")
                            .frame(width: 40, height: 50)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Hardle"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if gameModel.isGameOver() {
                        gameModel.resetGame()
                    }
                }
            )
        }
    }
}

struct LetterCell: View {
    let letter: Character?
    let status: GameModel.KeyStatus
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(width: 60, height: 60)
                .overlay(
                    Rectangle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            
            if let letter = letter {
                Text(String(letter))
                    .font(.system(size: 28, weight: .bold))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: letter)
            }
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .correct:
            return Color.green
        case .misplaced:
            return Color.yellow
        case .wrong:
            return Color.gray
        case .unused:
            return Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }
}

struct KeyboardKey: View {
    let char: Character
    let status: GameModel.KeyStatus
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(String(char))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .frame(width: 30, height: 50)
                .background(backgroundColor)
                .cornerRadius(5)
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .correct:
            return Color.green
        case .misplaced:
            return Color.yellow
        case .wrong:
            return Color.gray
        case .unused:
            return Color(UIColor.darkGray).opacity(0.7)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .misplaced:
            return Color(UIColor.darkText)
        default:
            return Color.white
        }
    }
} 