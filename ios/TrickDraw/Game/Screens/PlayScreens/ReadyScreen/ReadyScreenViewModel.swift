//
//  ReadyScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth

class ReadyScreenViewModel: ObservableObject {
    private var database: Firestore = Firestore.firestore()
    private let gameAPI: GameAPI = DefaultGameAPI.shared // TODO: Replace with DI
            
    private let gameId: String
    private let hostPlayerId: String
    
    var isHost: Bool {
        return gameAPI.currentUser.map { hostPlayerId == $0.uid } ?? false
    }
    
    @Published var players: [Player]
    @Published var playerIdsReady: [String]
    
    init(gameId: String,
         hostPlayerId: String,
         players: [Player],
         playerIdsReady: [String]) {
        self.gameId = gameId
        self.hostPlayerId = hostPlayerId
        self.players = players
        self.playerIdsReady = playerIdsReady
    }
    
    func readyUp() {
        gameAPI.readyUp(gameId, nil)
    }
    
    func startGame() {
        gameAPI.startGame(gameId, players, nil)
    }
}
