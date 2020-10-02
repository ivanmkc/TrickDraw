//
//  Player.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-19.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestoreSwift

struct Player: Identifiable, Codable, Hashable {
    let id: String
    let name: String
}

extension Player {
    static let player1 = Player(id: "player1", name: "Player 1")
    static let player2 = Player(id: "player2", name: "Player 2")
    static let player3 = Player(id: "player3", name: "Player 3")
}
