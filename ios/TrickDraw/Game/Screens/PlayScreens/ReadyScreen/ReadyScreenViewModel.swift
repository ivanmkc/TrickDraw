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
    
    private var gameReference: DocumentReference {
        return database.collection("games").document(gameId)
    }
    
    let gameId: String
    
    @Published var players: [Player]
    @Published var playerIdsReady: [String]
    
    init(gameId: String, players: [Player], playerIdsReady: [String]) {
        self.gameId = gameId
        self.players = players
        self.playerIdsReady = playerIdsReady
    }

    // Actions: Ready up
    func readyUp() {
        // TODO: Send to readyUp cloud function so users can only ready themselves
        if let playerId = Auth.auth().currentUser?.uid {
            gameReference.updateData(["playerIdsReady" : FieldValue.arrayUnion([playerId])])
        }
    }
}
