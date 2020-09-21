//
//  GameAPI.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-21.
//  Copyright © 2020 Google. All rights reserved.
//

import Firebase
import Combine

enum APIError: Error {
    case userNotLoggedIn
}

protocol GameAPI {
    var currentUser: User? { get }
    
    func createGame(_ completionHandler: ((Result<Void, Error>) -> ())?)
    func readyUp(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?)
    func startGame(_ gameId: String, _ players: [Player], _ completionHandler: ((Result<Void, Error>) -> ())?)
}

class DefaultGameAPI: GameAPI {
    static let shared = DefaultGameAPI() // TODO: Replace with DI framework
    private var database: Firestore = Firestore.firestore()

    init() {
    }
    
    var gamesReference: CollectionReference {
        return database.collection("games")
    }
    
    private func viewInfoCollectionReference(_ gameId: String) -> CollectionReference {
        return gamesReference.document(gameId).collection("viewInfo")
    }
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    func createGame(_ completionHandler: ((Result<Void, Error>) -> ())?) {
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
                .setData(from: PlayingReadyInfo(playerIdsReady: []))
            completionHandler?(.success(()))
        } catch (let error) {
            print("Error creating game: \(error.localizedDescription)")
            completionHandler?(.failure(error))
        }

    }
    
    func readyUp(_ gameId: String, _ completionHandler: ((Result<Void, Error>) -> ())?) {
        guard let playerId = currentUser?.uid else {
            completionHandler?(.failure(APIError.userNotLoggedIn))
            return
        }
        
        // TODO: Send to readyUp cloud function so users can only ready themselves
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
    
    func startGame(_ gameId: String, _ players: [Player], _ completionHandler: ((Result<Void, Error>) -> ())?) {
        guard let playerId = currentUser?.uid else {
            completionHandler?(.failure(APIError.userNotLoggedIn))
            return
        }
                
        gamesReference.document(gameId)
            .updateData(["state" : "guess"]) { (error) in
                if let error = error {
                    completionHandler?(.failure(error))
                } else {
                    
                    let artist = players.randomElement()!
                    let endTime = Date().addingTimeInterval(60)
                    let scoreboard = Scoreboard()
                    let question = ["TODO"].randomElement()!
                    
                    // TODO: Delete "ready" document

                    do {
                        // TODO: Send to readyUp cloud function so users can only ready themselves
                        try self.viewInfoCollectionReference(gameId)
                            .document("guess")
                            .setData(from: PlayingGuessInfo(common: DrawGuessCommonOnlineModel(artist: artist,
                                                                                               guessers: [],
                                                                                               question: question,
                                                                                               endTime: endTime,
                                                                                               guesses: []),
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
    }
}
