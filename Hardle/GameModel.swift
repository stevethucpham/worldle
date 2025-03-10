import Foundation

class GameModel: ObservableObject {
    // Game settings
    let wordLength = 5
    let maxAttempts = 6
    
    // Game state
    @Published var targetWord: String
    @Published var currentAttempt: Int = 0
    @Published var guesses: [[Character?]]
    @Published var keyboardStatus: [Character: KeyStatus] = [:]
    
    // Dictionary of valid words
    private var validWords: [String]
    // Cache for words we've already checked with the API
    private var wordValidationCache: [String: Bool] = [:]
    
    enum KeyStatus {
        case correct      // Green
        case misplaced    // Yellow
        case wrong        // Gray
        case unused       // Default
    }
    
    init() {
        // Capture wordLength locally to avoid using self in closure
        let length = wordLength
        
        // Load word list first
        if let path = Bundle.main.path(forResource: "words", ofType: "txt"),
           let content = try? String(contentsOfFile: path) {
            validWords = content.components(separatedBy: .newlines)
                               .filter { $0.count == length }
                               .map { $0.uppercased() }
        } else {
            validWords = ["SWIFT", "APPLE", "XCODE", "WORLD", "HELLO"]
        }
        
        // Initialize target word with a random word
        targetWord = validWords.randomElement() ?? "SWIFT"
        
        // Initialize guesses array
        guesses = Array(repeating: Array(repeating: nil, count: wordLength), count: maxAttempts)
        
        // Initialize keyboard
        keyboardStatus = [:]
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            keyboardStatus[char] = .unused
        }
    }
    
    func addLetter(_ letter: Character) {
        guard currentAttempt < maxAttempts else { return }
        
        // Find the first empty position in the current row
        if let emptyIndex = guesses[currentAttempt].firstIndex(where: { $0 == nil }) {
            guesses[currentAttempt][emptyIndex] = letter
        }
    }
    
    func removeLetter() {
        guard currentAttempt < maxAttempts else { return }
        
        // Find the last filled position in the current row
        if let lastFilledIndex = guesses[currentAttempt].lastIndex(where: { $0 != nil }) {
            guesses[currentAttempt][lastFilledIndex] = nil
        }
    }
    
    // Check if a word is valid using an API
    func isWordValid(_ word: String, completion: @escaping (Bool) -> Void) {
        let formattedWord = word.uppercased()
        
        // Check cache first
        if let isValid = wordValidationCache[formattedWord] {
            completion(isValid)
            return
        }
        
        // Check local list first
        if validWords.contains(formattedWord) {
            wordValidationCache[formattedWord] = true
            completion(true)
            return
        }
        
        // Use the Free Dictionary API to validate
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(formattedWord.lowercased())"
        
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                // Parse the JSON response
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]], !jsonArray.isEmpty {
                    // If we get a valid response with entries, the word exists
                    let isValid = !jsonArray.isEmpty && jsonArray[0] is [String: Any]
                    
                    // Cache the result
                    self.wordValidationCache[formattedWord] = isValid
                    
                    // If valid, add to our local list
                    if isValid {
                        self.validWords.append(formattedWord)
                    }
                    
                    DispatchQueue.main.async {
                        completion(isValid)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    // Modified submitGuess to use the API validation
    func submitGuess(completion: @escaping (Bool) -> Void) {
        guard currentAttempt < maxAttempts else {
            completion(false)
            return
        }
        
        // Check if the current row is completely filled
        let currentGuess = guesses[currentAttempt]
        guard !currentGuess.contains(nil) else {
            completion(false)
            return
        }
        
        // Convert current guess to string
        let guessString = String(currentGuess.compactMap { $0 })
        
        // Check if the guess is a valid word using the API
        isWordValid(guessString) { isValid in
            if isValid {
                // Update keyboard status
                self.updateKeyboardStatus(for: guessString)
                
                // Move to next attempt
                self.currentAttempt += 1
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateKeyboardStatus(for guess: String) {
        let targetChars = Array(targetWord)
        let guessChars = Array(guess)
        
        // First pass: mark correct letters
        for i in 0..<wordLength {
            if guessChars[i] == targetChars[i] {
                keyboardStatus[guessChars[i]] = .correct
            }
        }
        
        // Second pass: mark misplaced letters
        for i in 0..<wordLength {
            if guessChars[i] != targetChars[i] {
                if targetWord.contains(guessChars[i]) {
                    // Only mark as misplaced if not already marked as correct
                    if keyboardStatus[guessChars[i]] != .correct {
                        keyboardStatus[guessChars[i]] = .misplaced
                    }
                } else {
                    keyboardStatus[guessChars[i]] = .wrong
                }
            }
        }
    }
    
    func getLetterStatus(row: Int, column: Int) -> KeyStatus {
        guard row < currentAttempt, let letter = guesses[row][column] else {
            return .unused
        }
        
        let targetChars = Array(targetWord)
        
        if letter == targetChars[column] {
            return .correct
        } else if targetWord.contains(letter) {
            return .misplaced
        } else {
            return .wrong
        }
    }
    
    func isGameOver() -> Bool {
        // Game is over if player has used all attempts or has guessed the word
        if currentAttempt >= maxAttempts {
            return true
        }
        
        if currentAttempt > 0 {
            let lastGuess = String(guesses[currentAttempt - 1].compactMap { $0 })
            if lastGuess == targetWord {
                return true
            }
        }
        
        return false
    }
    
    func resetGame() {
        targetWord = validWords.randomElement() ?? "SWIFT"
        currentAttempt = 0
        guesses = Array(repeating: Array(repeating: nil, count: wordLength), count: maxAttempts)
        
        // Reset keyboard
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            keyboardStatus[char] = .unused
        }
    }
} 
