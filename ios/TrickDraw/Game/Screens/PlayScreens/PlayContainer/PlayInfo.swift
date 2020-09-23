//
//  PlayInfo.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-22.
//  Copyright © 2020 Google. All rights reserved.
//

import PencilKit

struct PlayReadyInfo: Codable {
    let playerIdsReady: [String]
}

struct PlayAnswerInfo: Codable {
    let artist: Player
    let guessers: [Player]
    let question: String

    let correctPlayer: Player
    let scoreboard: Scoreboard
}

struct PlayGuessInfo: Codable {
    let artist: Player
    let guessers: [Player]
    
    let question: String
    let choices: [String]
    
    let endTime: Date
    
    let guesses: [Guess]
    
    let drawingAsBase64: String?

    let scoreboard: Scoreboard
}

extension PlayGuessInfo {
    var drawing: PKDrawing? {
        if let drawingAsBase64 = drawingAsBase64, let drawing = try? PKDrawing(base64Encoded: drawingAsBase64) {
            return drawing
        } else {
            return nil
        }
    }
}

extension PKDrawing {
    enum DecodingError: Error {
        case decodingError
    }
    
    init(base64Encoded base64: String) throws {
        guard let data = Data(base64Encoded: base64) else {
            throw DecodingError.decodingError
        }
        try self.init(data: data)
    }
}
