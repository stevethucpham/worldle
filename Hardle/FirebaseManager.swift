//import Firebase
//import FirebaseFirestore
//
//class FirebaseManager: ObservableObject {
//    private let db = Firestore.firestore()
//    @Published var activeGames: [GameSession] = []
//    
//    struct GameSession: Identifiable {
//        let id: String
//        let creatorId: String
//        let opponentId: String?
//        let targetWord: String
//        let status: GameStatus
//        
//        enum GameStatus: String {
//            case waiting
//            case active
//            case completed
//        }
//    }
//    
//    func createGame(targetWord: String, userId: String) {
//        let gameRef = db.collection("games").document()
//        
//        let game = [
//            "creatorId": userId,
//            "opponentId": nil,
//            "targetWord": targetWord,
//            "status": "waiting",
//            "createdAt": FieldValue.serverTimestamp()
//        ]
//        
//        gameRef.setData(game) { error in
//            if let error = error {
//                print("Error creating game: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func joinGame(gameId: String, userId: String) {
//        let gameRef = db.collection("games").document(gameId)
//        
//        gameRef.updateData([
//            "opponentId": userId,
//            "status": "active"
//        ]) { error in
//            if let error = error {
//                print("Error joining game: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func listenForGames(userId: String) {
//        // Listen for games where user is creator or opponent
//        db.collection("games")
//            .whereFilter(Filter.orFilter([
//                Filter.whereField("creatorId", isEqualTo: userId),
//                Filter.whereField("opponentId", isEqualTo: userId)
//            ]))
//            .addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                self.activeGames = documents.compactMap { document -> GameSession? in
//                    let data = document.data()
//                    
//                    guard let creatorId = data["creatorId"] as? String,
//                          let targetWord = data["targetWord"] as? String,
//                          let statusString = data["status"] as? String,
//                          let status = GameSession.GameStatus(rawValue: statusString) else {
//                        return nil
//                    }
//                    
//                    return GameSession(
//                        id: document.documentID,
//                        creatorId: creatorId,
//                        opponentId: data["opponentId"] as? String,
//                        targetWord: targetWord,
//                        status: status
//                    )
//                }
//            }
//    }
//} 
