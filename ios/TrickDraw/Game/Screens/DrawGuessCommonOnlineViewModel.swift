//
//  DrawGuessCommonOnlineViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import Foundation

struct DrawGuessCommonOnlineModel {
    let artist: Player
    let guessers: [Player]
    let question: String
    
    let endTime: Date
    
    let guesses: [(Player, String)]
}
