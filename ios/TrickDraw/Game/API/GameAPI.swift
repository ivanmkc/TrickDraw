//
//  GameAPI.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-21.
//  Copyright © 2020 Google. All rights reserved.
//

import Firebase
import Combine
import PencilKit

enum APIError: Error {
    case userNotLoggedIn
}

protocol GameAPI {
    func viewInfoCollectionReference(_ gameId: String) -> CollectionReference
    
    var currentUser: User? { get }
    
    func createGame(_ completionHandler: ((Result<String, Error>) -> ())?)
    
    func joinGame(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    
    func readyUp(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    func startGame(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    
    func updateDrawing(_ gameId: String, drawing: PKDrawing, _ completionHandler: ((Result<Void, Error>) -> ())?)
    
    func submitGuessByPlayer(_ gameId: String, guess: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    func submitGuessByAI(_ gameId: String, guess: String, confidence: Float, _ completionHandler: ((Result<Void, Error>) -> ())?)
}

class DefaultGameAPI: GameAPI {
    struct Constants {
        static let numChoices = 8
    }
    
    static let shared = DefaultGameAPI() // TODO: Replace with DI framework
    private var database: Firestore = Firestore.firestore()
    private var labels = QuickDrawModelDataHandler.shared.labels! // TODO: Replace with DI framework
    
    init() {
    }
    
    var gamesReference: CollectionReference {
        return database.collection("games")
    }
    
    func viewInfoCollectionReference(_ gameId: String) -> CollectionReference {
        return gamesReference.document(gameId).collection("viewInfo")
    }
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    func createGame(_ completionHandler: ((Result<String, Error>) -> ())?) {
        do {
            guard let currentUser = Auth.auth().currentUser,
                  let displayName = currentUser.displayName else { return }
            
            let userId = currentUser.uid
            let player = Player(id: userId, name: displayName)
            
            let gameReference = try gamesReference.addDocument(from: Game(name: "\(displayName)'s game",
                                                                          players: [player],
                                                                          hostPlayerId: userId,
                                                                          state: GameState.ready))
            try gameReference
                .collection("viewInfo")
                .document("ready")
                .setData(from: PlayReadyInfo(playerIdsReady: []))
            
            completionHandler?(.success(gameReference.documentID))
        } catch (let error) {
            print("Error creating game: \(error.localizedDescription)")
            completionHandler?(.failure(error))
        }
    }
        
    func joinGame(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        guard let currentUser = currentUser,
              let displayName = currentUser.displayName else {
            completionHandler?(.failure(APIError.userNotLoggedIn))
            return
        }
        
        let player = ["id": currentUser.uid, "name": displayName]
        
        gamesReference
            .document(gameId)
            .updateData(["players" : FieldValue.arrayUnion([player])]) {
                if let error = $0 {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.success(()))
                }
            }
    }
    
    func readyUp(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        guard let playerId = currentUser?.uid else {
            completionHandler?(.failure(APIError.userNotLoggedIn))
            return
        }
        
        viewInfoCollectionReference(gameId)
            .document("ready")
            .updateData(["playerIdsReady" : FieldValue.arrayUnion([playerId])]) {
                if let error = $0 {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.success(()))
                }
            }
    }
    
    func startGame(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        let gameReference = gamesReference.document(gameId)
        
        gameReference.getDocument { (snapshot, error) in
            if let error = error {
                completionHandler?(.failure(error))
                return
            } else {
                do {
                    guard let game = try snapshot?.data(as: Game.self) else {
                        return
                    }
                    
                    let players = game.players
                    
                    gameReference
                        .updateData(["state" : "guess"]) { [weak self] (error) in
                            guard let `self` = self else { return }
                            
                            if let error = error {
                                completionHandler?(.failure(error))
                                return
                            } else {
                                
                                let artist = players.randomElement()!
                                let endTime = Date().addingTimeInterval(60)
                                let scoreboard = Scoreboard()
                                let question = self.labels.randomElement()!
                                
                                var choices = self.labels
                                choices.removeAll { $0 == question }
                                
                                choices = (choices.shuffled().prefix(Constants.numChoices - 1) + [question])
                                    .sorted()
                                
                                // TODO: Delete "ready" document
                                
                                do {
                                    // TODO: Send to readyUp cloud function so users can only ready themselves
                                    try self.viewInfoCollectionReference(gameId)
                                        .document("guess")
                                        .setData(from: PlayGuessInfo(artist: artist,
                                                                     guessers: [],
                                                                     question: question,
                                                                     choices: choices,
                                                                     endTime: endTime,
                                                                     guesses: [],
                                                                     drawingAsBase64: nil,
                                                                     scoreboard: scoreboard)) {
                                            if let error = $0 {
                                                completionHandler?(.failure(error))
                                            } else {
                                                completionHandler?(.success(()))
                                            }
                                        }
                                } catch (let error) {
                                    completionHandler?(.failure(error))
                                }
                            }
                        }

                } catch (let error) {
                    completionHandler?(.failure(error))
                    return
                }
            }
        }
    }
    
    func updateDrawing(_ gameId: String, drawing: PKDrawing, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        let drawingAsBase64 = drawing.dataRepresentation().base64EncodedString()
        
        self.viewInfoCollectionReference(gameId)
            .document("guess")
            .updateData(["drawingAsBase64": drawingAsBase64]) {
                if let error = $0 {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.success(()))
                }
            }
    }
    
    func submitGuessByPlayer(_ gameId: String, guess: String, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        if let currentUser = currentUser {
            submitGuess(gameId, player: Player(id: currentUser.uid, name: currentUser.displayName ?? ""),
                        guess: guess,
                        confidence: 1.0,
                        completionHandler)
        }
    }
    
    func submitGuessByAI(_ gameId: String, guess: String, confidence: Float, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        submitGuess(gameId, player: GlobalConstants.GoogleBot, guess: guess, confidence: confidence, nil)
    }
    
    private func submitGuess(_ gameId: String, player: Player, guess: String, confidence: Float, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        print("'\(player.name)' submitting \(guess)")
        
        let guess = Guess(playerId: player.id,
                          playerName: player.name,
                          guess: guess,
                          confidence: confidence)
        
        let dict: [String : Any] = ["id": guess.id,
                    "playerId": guess.playerId,
                    "playerName": guess.playerName,
                    "confidence": guess.confidence,
                    "guess": guess.guess]
        
        self.viewInfoCollectionReference(gameId)
            .document("guess")
            .updateData(["guesses": FieldValue.arrayUnion([dict])]) {
                if let error = $0 {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.success(()))
                }
            }
    }
}
