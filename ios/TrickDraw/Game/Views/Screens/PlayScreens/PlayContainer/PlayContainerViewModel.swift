//
//  PlayScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

enum GameStateWrapper {
    case ready(PlayReadyInfo)
    case guess(PlayGuessInfo)
    case answer(PlayAnswerInfo)
}

class PlayContainerViewModel: ObservableObject {
    private let gameAPI: GameAPI = DefaultGameAPI.shared
    private var viewInfoListener: ListenerRegistration?
    
    private let state: GameState
    
    let gameId: String
    let hostPlayerId: String
    
    @Published var isHost: Bool
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
        self.isHost = gameAPI.currentUser.map { $0.uid == hostPlayerId } ?? false
        
        fetchData()
    }
    
    private func fetchData() {
        viewInfoListener = gameAPI
            .viewInfoCollectionReference(gameId)
            .addSnapshotListener { documentSnapshot, error in
            let state = self.state
            
            switch (state) {
            case .ready:
                self.gameAPI
                    .viewInfoCollectionReference(self.gameId)
                    .document(state.rawValue)
                    .getDocument(completion: { [weak self] (snapshot, error) in
                        guard let `self` = self else { return }
                        
                        do {
                            if let error = error {
                                self.stateInfo = .failure(error)
                            } else {
                                if let info = try snapshot?.data(as: PlayReadyInfo.self) {
                                    self.stateInfo = .success(GameStateWrapper.ready(info))
                                }
                            }
                        } catch (let error) {
                            self.stateInfo = .failure(error)
                        }
                    })
            case .guess:
                self.gameAPI
                    .viewInfoCollectionReference(self.gameId)
                    .document(state.rawValue)
                    .getDocument(completion: { [weak self] (snapshot, error) in
                        guard let `self` = self else { return }
                        
                        do {
                            if let error = error {
                                self.stateInfo = .failure(error)
                            } else {
                                if let info = try snapshot?.data(as: PlayGuessInfo.self) {
                                    self.stateInfo = .success(GameStateWrapper.guess(info))
                                }
                            }
                        } catch (let error) {
                            self.stateInfo = .failure(error)
                        }
                    })
            case .answer:
                self.gameAPI
                    .viewInfoCollectionReference(self.gameId)
                    .document(state.rawValue)
                    .getDocument(completion: { [weak self] (snapshot, error) in
                        guard let `self` = self else { return }
                        
                        do {
                            if let error = error {
                                self.stateInfo = .failure(error)
                            } else {
                                if let info = try snapshot?.data(as: PlayAnswerInfo.self) {
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
        self.gameAPI
            .viewInfoCollectionReference(gameId)
            .document(gameState.rawValue)
            .getDocument(completion: { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                
                do {
                    if let error = error {
                        self.stateInfo = .failure(error)
                    } else {
                        if let info = try snapshot?.data(as: PlayReadyInfo.self) {
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

typealias Scoreboard = [String: Int]
