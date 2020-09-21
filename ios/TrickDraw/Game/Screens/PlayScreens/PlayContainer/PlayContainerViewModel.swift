//
//  PlayScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

enum LoadableResult<Result, Error> {
    case loading
    case success(Result)
    case failure(Error)
}

enum GameStateWrapper {
    case ready(PlayingReadyInfo)
    case guess(PlayingGuessInfo)
    case answer(PlayingAnswerInfo)
}

class PlayContainerViewModel: ObservableObject {
    private var database: Firestore = Firestore.firestore()
    private var viewInfoListener: ListenerRegistration?
    
    private var viewInfoCollectionReference: CollectionReference
    
    let gameId: String
    let hostPlayerId: String
    let state: GameState
    @Published var players: [Player]
    @Published var stateInfo: LoadableResult<GameStateWrapper, Error> = .loading
        
    init(gameId: String,
         hostPlayerId: String,
         players: [Player],
         state: GameState) {
        self.gameId = gameId
        self.hostPlayerId = hostPlayerId
        self.players = players
        self.state = state
        
        viewInfoCollectionReference = database
            .collection("games")
            .document(gameId)
            .collection("viewInfo")
        
        fetchData()
    }
    
    private func fetchData() {
        viewInfoListener = viewInfoCollectionReference.addSnapshotListener { documentSnapshot, error in
            let state = self.state
            
            switch (state) {
            case .ready:
                self.viewInfoCollectionReference
                    .document(state.rawValue)
                    .getDocument(completion: { [weak self] (snapshot, error) in
                        guard let `self` = self else { return }
                        
                        do {
                            if let error = error {
                                self.stateInfo = .failure(error)
                            } else {
                                if let info = try snapshot?.data(as: PlayingReadyInfo.self) {
                                    self.stateInfo = .success(GameStateWrapper.ready(info))
                                }
                            }
                        } catch (let error) {
                            self.stateInfo = .failure(error)
                        }
                    })
            case .guess:
                self.viewInfoCollectionReference
                    .document(state.rawValue)
                    .getDocument(completion: { [weak self] (snapshot, error) in
                        guard let `self` = self else { return }
                        
                        do {
                            if let error = error {
                                self.stateInfo = .failure(error)
                            } else {
                                if let info = try snapshot?.data(as: PlayingGuessInfo.self) {
                                    self.stateInfo = .success(GameStateWrapper.guess(info))
                                }
                            }
                        } catch (let error) {
                            self.stateInfo = .failure(error)
                        }
                    })
            case .answer:
                self.viewInfoCollectionReference
                    .document(state.rawValue)
                    .getDocument(completion: { [weak self] (snapshot, error) in
                        guard let `self` = self else { return }
                        
                        do {
                            if let error = error {
                                self.stateInfo = .failure(error)
                            } else {
                                if let info = try snapshot?.data(as: PlayingAnswerInfo.self) {
                                    self.stateInfo = .success(GameStateWrapper.answer(info))
                                }
                            }
                        } catch (let error) {
                            self.stateInfo = .failure(error)
                        }
                    })
            }
        }
    }
    
    private func fetchGameStateInfo(_ gameState: GameState,
                                    completionHandler: () -> LoadableResult<GameStateWrapper, Error>) {
        self.viewInfoCollectionReference
            .document(gameState.rawValue)
            .getDocument(completion: { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                
                do {
                    if let error = error {
                        self.stateInfo = .failure(error)
                    } else {
                        if let info = try snapshot?.data(as: PlayingReadyInfo.self) {
                            self.stateInfo = .success(GameStateWrapper.ready(info))
                        }
                    }
                } catch (let error) {
                    self.stateInfo = .failure(error)
                }
            })
    }
    
    deinit {
        viewInfoListener?.remove()
    }
}

typealias Scoreboard = [Player: Int]

struct PlayingReadyInfo: Codable {
    let playerIdsReady: [String]
}

struct PlayingGuessInfo: Codable {
    let artist: Player
    let guessers: [Player]
    let question: String
    
    let endTime: Date
    
    let guesses: [Guess]
    
    let drawingAsBase64: String?

    let scoreboard: Scoreboard
}

struct PlayingAnswerInfo: Codable {
    let artist: Player
    let guessers: [Player]
    let question: String

    let correctPlayer: Player
    let scoreboard: Scoreboard
}
