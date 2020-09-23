//
//  LobbyScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

enum GameState: String, Codable {
    case ready
    case guess
    case answer
}

struct Game: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    
    let name: String
    var players: [Player] = []
    var hostPlayerId: String
    var state: GameState
}

class LobbyScreenViewModel: ObservableObject {
    private var gamesListener: ListenerRegistration?
    private let gameAPI = DefaultGameAPI.shared
    
    @Published var games: [Game] = []
    
    init() {
        setupListener()
    }
    
    func setupListener() {
        gamesListener = gameAPI
            .gamesReference
            .addSnapshotListener { querySnapshot, error in
            // TODO: Sort by creation date
            guard let documents = querySnapshot?.documents else {
                print("Error listening for games updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            self.games = documents.compactMap { queryDocumentSnapshot -> Game? in
                do {
                    return try queryDocumentSnapshot.data(as: Game.self)
                } catch (let error) {
                    print("Error serializing game: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
    
    func createGame(_ completionHandler: ((Result<String, Error>) -> ())?) {
        gameAPI.createGame { (result) in
            switch result {
            case .success(let gameId):
                // Start game right away. This skips the ready screen
                self.gameAPI.startGame(gameId) { _ in
                    completionHandler?(result)
                }
            case .failure:
                // TODO: Show failure toast
                break
            }
        }
    }
    
    func joinGame(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        gameAPI.joinGame(gameId, completionHandler)
    }
    
    deinit {
        gamesListener?.remove()
    }
}
