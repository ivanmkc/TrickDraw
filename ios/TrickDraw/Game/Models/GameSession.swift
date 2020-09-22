//
//  GameSession.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-17.
//  Copyright © 2020 Google. All rights reserved.
//
import Foundation

enum AnswerState {
    case correct(Player)
    case incorrect
}

extension Player {
    static let player1 = Player(id: "player1", name: "Player 1")
    static let player2 = Player(id: "player2", name: "Player 2")
    static let player3 = Player(id: "player3", name: "Player 3")
}

//func processGuess(guess: String) {
//    if (guess == answer) {
//        // Proceed to next answer
//
//        answer = candidates.random()
//    }
//}

struct StartScreenViewModel {
    
    
    // Actions: Start new game, join existing lobby
    func startGame() {
        
    }
    
    func joinLobby(lobby: String) {
        
    }
}
