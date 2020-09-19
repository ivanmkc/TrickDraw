//
//  ReadyScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestore

class ReadyScreenViewModel: ObservableObject {
    private var database: Firestore = Firestore.firestore()
    private var readyListener: ListenerRegistration?
    
    private var gameReference: DocumentReference {
        return database.collection("games").document(gameId)
    }
    
    let gameId: String
    
    @Published var playersReady: [Player: Bool] = [:]
    
    init(gameId: String, playersReady: [Player: Bool]) {
        self.gameId = gameId
        self.playersReady = playersReady
    }

    // Actions: Ready up
    func readyUp() {
        // Send to readyUp cloud function
        
    }
}
