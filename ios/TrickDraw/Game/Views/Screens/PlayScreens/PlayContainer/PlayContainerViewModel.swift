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
    private var scoreboardListener: ListenerRegistration?
    
    private let state: GameState
    
    let gameId: String
    let hostPlayerId: String
    
    @Published var scoreboard: Scoreboard = [:]
    @Published var isHost: Bool
    @Published var playerId: String?
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
        self.playerId = gameAPI.currentUser?.uid
        self.isHost = gameAPI.currentUser.map { $0.uid == hostPlayerId } ?? false
        
        self.setupListeners()
    }
    
    private func setupListeners() {
        setupScoreboardListener()
        setupViewInfoListener()
    }
    
    private func setupScoreboardListener() {
        viewInfoListener = self.gameAPI
            .scoreboardReference(gameId)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let `self` = self else { return }
                
                do {
                    if let error = error {
                        self.stateInfo = .failure(error)
                    } else {
                        if let scoreboard = try snapshot?.data(as: Scoreboard.self) {
                            self.scoreboard = scoreboard
                        }
                    }
                } catch (let error) {
                    // TODO: Show error toast
                }

            }
    }
    
    private func setupViewInfoListener() {
        switch (state) {
        case .ready:
            viewInfoListener = self.gameAPI
                .viewInfoCollectionReference(self.gameId)
                .document(state.rawValue)
                .addSnapshotListener { [weak self] (snapshot, error) in
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
                        
                        // TODO: Show error toast
                    }
                }
        case .guess:
            viewInfoListener = self.gameAPI
                .viewInfoCollectionReference(self.gameId)
                .document(state.rawValue)
                .addSnapshotListener { [weak self] (snapshot, error) in
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
                }
        case .answer:
            viewInfoListener = self.gameAPI
                .viewInfoCollectionReference(self.gameId)
                .document(state.rawValue)
                .addSnapshotListener { [weak self] (snapshot, error) in
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
                }
        }
    }
    
    deinit {
        viewInfoListener?.remove()
        scoreboardListener?.remove()
    }
}

typealias Scoreboard = [String: Int]
