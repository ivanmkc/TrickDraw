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

enum PlayingState {
    case ready
    case guess
    case answer(AnswerState)
}

enum GameState {
    case lobby
    case playing(PlayingState)
    case scoreboard
}

struct GameSession {
    
    let dynamicLinkUrl: URL
    
    let host: Player
    
    let artist: Player
    let answer: String // How to make this only visible to the artist?
    
    let guesses: [Guess]
    
    let state: GameState
}

struct Guess {
    let player: Player
    let guess: String
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

struct ReadyScreenViewModel {
    var players: [Player]
    
    // Actions: Ready up
    func readyUp() {
        
    }
}

