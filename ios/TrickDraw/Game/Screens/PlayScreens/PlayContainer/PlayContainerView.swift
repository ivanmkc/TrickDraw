//
//  PlayScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

enum LoadableResult<Result, Error> {
    case loading
    case success(Result)
    case failure(Error)
}

struct GameInfo: Codable {
    var state: PlayingState
    
    init(state: PlayingState) {
        self.state = state
    }
    enum CodingKeys: CodingKey {
        case ready, guess, answer
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch state {
        case .ready(let info):
            try container.encode(info, forKey: .ready)
        case .guess(let info):
            try container.encode(info, forKey: .guess)
        case .answer(let info):
            try container.encode(info, forKey: .answer)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let key = container.allKeys.first {
            switch key {
            case .ready:
                let info = try container.decode(
                    PlayingReadyInfo.self,
                    forKey: .ready
                )
                self = GameInfo(state: .ready(info))
            case .guess:
                let info = try container.decode(
                    PlayingGuessInfo.self,
                    forKey: .guess
                )
                self = GameInfo(state: .guess(info))
            case .answer:
                let info = try container.decode(
                    PlayingAnswerInfo.self,
                    forKey: .answer
                )
                self = GameInfo(state: .answer(info))
            }
        } else {
            throw ClassificationError.invalidImage // TODO
        }
    }

}

class PlayContainerViewModel: ObservableObject {
    private var database: Firestore = Firestore.firestore()
    
    private var gameReference: DocumentReference
    
    var gameId: String
    @Published var players: [Player]
    
    @Published var state: LoadableResult<PlayingState, Error> = .loading
        
    init(gameId: String, players: [Player]) {
        self.gameId = gameId
        self.players = players
        gameReference = database.collection("games").document(gameId).collection("gameinfo").document("state")
        
        fetchData()
    }
    
    private func fetchData() {
        gameReference.addSnapshotListener { documentSnapshot, error in
            // TODO: Sort by creation date
            do {
                guard let gameInfo = try documentSnapshot?.data(as: GameInfo.self) else {
                    return
                }
            
                self.state = .success(gameInfo.state)
            } catch (let error) {
                self.state = .failure(error)
            }
        }
    }
}

typealias Scoreboard = [Player: Int]

struct PlayingReadyInfo: Codable {
    let playerIdsReady: [String]
}

struct PlayingGuessInfo: Codable {
    let gameId: String
    let common: DrawGuessCommonOnlineModel
    let scoreboard: Scoreboard
}

struct PlayingAnswerInfo: Codable {
    let gameId: String
    let common: DrawGuessCommonOnlineModel
    let correctPlayer: Player
    let scoreboard: Scoreboard
}

enum PlayingState {
    case ready(PlayingReadyInfo)
    case guess(PlayingGuessInfo)
    case answer(PlayingAnswerInfo)
}

struct PlayContainerView: View {
    @ObservedObject
    var viewModel: PlayContainerViewModel
    
    var body: some View {
        return AnyView(createView())
    }
    
    private func createView() -> AnyView {
        switch viewModel.state {
        case .loading:
            return AnyView(Text("Loading..."))
        case .success(let playState):
            switch playState {
            case .ready(let info):
                return AnyView(ReadyScreenView(viewModel: ReadyScreenViewModel(gameId: viewModel.gameId,
                                                                               players: viewModel.players,
                                                                               playerIdsReady: info.playerIdsReady)))
            case .guess(let info):
                return AnyView(
                    DrawScreenView(
                        viewModel: DrawScreenViewModel(
                            onlineModel: DrawScreenOnlineModel(common: info.common))))
            case .answer(let info):
                return AnyView(Text("TODO"))
            }
        case .failure(let error):
            return AnyView(Text("Loading: \(error.localizedDescription)"))
        }
    }
}
