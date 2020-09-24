//
//  GuessScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-22.
//  Copyright © 2020 Google. All rights reserved.
//

import Foundation
import PencilKit
import Combine

class GuessScreenViewModel: NSObject, ObservableObject {
    
    // Server
    private let gameApi: GameAPI = DefaultGameAPI.shared
    
    private let gameId: String
    @Published var scoreboard: Scoreboard
    @Published var onlineInfo: PlayGuessInfo
    @Published var drawing: PKDrawing?
    
    private let allLabels = QuickDrawModelDataHandler.shared.labels!
    
    // Local
    var aiWarnings: String? = nil
    
    init(gameId: String,
         scoreboard: Scoreboard,
         onlineInfo: PlayGuessInfo) {
        self.gameId = gameId
        self.scoreboard = scoreboard
        self.onlineInfo = onlineInfo
        self.drawing = onlineInfo.drawing
    }
    
    func submitGuess(guess: String) {
        gameApi.submitGuessByPlayer(gameId, guess: guess, isCorrect: guess == onlineInfo.question,  nil)
    }
}
