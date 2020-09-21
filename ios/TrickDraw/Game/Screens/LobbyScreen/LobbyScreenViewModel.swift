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
    
    @Published var didJoinSuccessfully: Bool = false
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
    
    func createGame() {
        gameAPI.createGame(nil)
    }
    
    func joinGame(_ gameId: String) {
        gameAPI.joinGame(gameId) {
            switch ($0) {
            case .success:
                self.didJoinSuccessfully = true
            case .failure:
                break // TODO: Handle failure
            }
        }
    }
    
    deinit {
        gamesListener?.remove()
    }
}
