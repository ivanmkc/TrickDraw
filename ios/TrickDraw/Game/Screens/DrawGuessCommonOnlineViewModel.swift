//
//  DrawGuessCommonOnlineViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import Foundation

struct Guess: Codable {
    let playerId: String
    let guess: String
}

struct DrawGuessCommonOnlineModel: Codable {
    let artist: Player
    let guessers: [Player]
    let question: String
    
    let endTime: Date
    
    let guesses: [Guess]
}
