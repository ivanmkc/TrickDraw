//
//  DrawGuessCommonOnlineViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestoreSwift

struct Guess: Identifiable, Codable {
    // This treats each guess as unique even if the other data is the same
    // Allows for array unions to work correctly
    var id: String = UUID().uuidString
    
    let playerId: String
    let playerName: String
    let guess: String
    let confidence: Float
    var isCorrect: Bool = false
}
