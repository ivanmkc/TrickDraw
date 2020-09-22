//
//  DrawGuessCommonOnlineViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestoreSwift

struct Guess: Identifiable, Codable {
    var id: String = UUID().uuidString
    
    let playerId: String
    let playerName: String
    let guess: String
}
