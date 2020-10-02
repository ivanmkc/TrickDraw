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
    case deserializationError
}

protocol GameAPI {
    func viewInfoCollectionReference(_ gameId: String) -> CollectionReference
    func scoreboardReference(_ gameId: String) -> DocumentReference
    
    var currentUser: User? { get }
    
    func createGame(_ completionHandler: ((Result<String, Error>) -> ())?)
    
    func joinGame(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    
    func readyUp(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    func startNewRound(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    
    func updateDrawing(_ gameId: String, drawing: PKDrawing, _ completionHandler: ((Result<Void, Error>) -> ())?)
    
    func submitGuessByPlayer(_ gameId: String, guess: String, isCorrect: Bool, _ completionHandler: ((Result<Void, Error>) -> ())?)
    func submitGuessByAI(_ gameId: String, guess: String, confidence: Float, isCorrect: Bool, _ completionHandler: ((Result<Void, Error>) -> ())?)
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
    
    func scoreboardReference(_ gameId: String) -> DocumentReference {
        return viewInfoCollectionReference(gameId).document("scoreboard")
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
                                                                          state: GameState.ready,
                                                                          scoreboard: [:],
                                                                          createdAt: Date()))
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
    
    func startNewRound(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        let gameReference = gamesReference.document(gameId)
        
        // TODO: Use transaction instead
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
                                                                     drawingAsBase64: nil)) {
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
    
    func submitGuessByPlayer(_ gameId: String, guess: String, isCorrect: Bool, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        if let currentUser = currentUser {
            submitGuess(gameId, player: Player(id: currentUser.uid, name: currentUser.displayName ?? ""),
                        guess: guess,
                        isCorrect: isCorrect,
                        confidence: 1.0,
                        completionHandler)
        }
    }
    
    func submitGuessByAI(_ gameId: String, guess: String, confidence: Float, isCorrect: Bool, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        submitGuess(gameId, player: GlobalConstants.GoogleBot, guess: guess, isCorrect: isCorrect, confidence: confidence, nil)
    }
    
    private func submitGuess(_ gameId: String, player: Player, guess: String, isCorrect: Bool, confidence: Float, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        print("'\(player.name)' submitting \(guess)")
        
        let guess = Guess(playerId: player.id,
                          playerName: player.name,
                          guess: guess,
                          confidence: confidence,
                          isCorrect: isCorrect)
        
        let guessAsDictionary: [String : Any] = ["id": guess.id,
                                    "playerId": guess.playerId,
                                    "playerName": guess.playerName,
                                    "confidence": guess.confidence,
                                    "guess": guess.guess,
                                    "isCorrect" : guess.isCorrect]
        
        self.database.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let viewInfoReference = self.viewInfoCollectionReference(gameId).document("guess")
                // Read: Get current guesses
                guard let playGuessInfo = try transaction.getDocument(viewInfoReference).data(as: PlayGuessInfo.self) else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve game from snapshot \(viewInfoReference)"
                        ]
                    )

                    errorPointer?.pointee = error
                    return nil
                }
                
                // Make sure no one has guessed correctly already
                guard !playGuessInfo.isFinished else { return nil }
                
                // Read: Get current scoreboard
                let scoreboardReference = self.scoreboardReference(gameId)
                
                var scoreboard: Scoreboard
                
                if try transaction
                    .getDocument(scoreboardReference)
                    .exists {
                    
                    guard let scoreboardExisting = try transaction
                    .getDocument(scoreboardReference).data() as? Scoreboard else {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve scoreboard from snapshot \(scoreboardReference)"
                            ]
                        )

                        errorPointer?.pointee = error
                        return nil
                    }

                    scoreboard = scoreboardExisting
                } else {
                    scoreboard = [:]
                }
                
                // Write: Update guesses
                transaction.updateData(
                    [
                        "guesses": FieldValue.arrayUnion([guessAsDictionary]),
                    ],
                    forDocument: viewInfoReference)
                
                if guess.isCorrect {
                    /// Write:  scoreboard
                    scoreboard[guess.playerId] = scoreboard[guess.playerId, default: 0] + 1

                    transaction.setData(scoreboard, forDocument: scoreboardReference)
                }

                return nil
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
        } completion: { (object, error) in
            if let error = error {
                completionHandler?(.failure(error))
            } else {
                completionHandler?(.success(()))
            }
        }
    }
}
