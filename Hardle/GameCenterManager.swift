import GameKit

class GameCenterManager: NSObject, ObservableObject, GKGameCenterControllerDelegate {
    @Published var isAuthenticated = false
    
    override init() {
        super.init()
        authenticatePlayer()
    }
    
    func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // Present the view controller for authentication
                // You'll need to use UIKit integration here
            } else if localPlayer.isAuthenticated {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
                print("Game Center authentication failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        // Dismiss the game center view controller
    }
    
    func sendChallenge(word: String, to friends: [GKPlayer]) {
        // Implement challenge functionality
    }
}

struct GameStats {
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var currentStreak: Int = 0
    var maxStreak: Int = 0
    var guessDistribution: [Int: Int] = [1:0, 2:0, 3:0, 4:0, 5:0, 6:0]
    
    var winPercentage: Int {
        return gamesPlayed > 0 ? Int((Double(gamesWon) / Double(gamesPlayed)) * 100) : 0
    }
} 