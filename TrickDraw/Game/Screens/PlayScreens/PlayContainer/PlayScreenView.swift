//
//  PlayScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

enum LoadableResult<Result, Error> {
    case loading
    case success(Result)
    case failure(Error)
}

class PlayContainerViewModel: ObservableObject {
    //    let question: String
    //
    //    let artist: Player
    //    let answer: String // How to make this only visible to the artist?
    //
    //    let guesses: [Guess]
    
    @Published var players: [Player] = []
    @Published var state: LoadableResult<PlayingState, Error> = .loading
    
    init() {    
        fetchData()
    }
    
    private func fetchData() {
        
    }
}

typealias Scoreboard = [Player: Int]

enum PlayingState {
    case ready(gameId: String, playersReady: [Player: Bool])
    case guess(gameId: String, common: DrawGuessCommonOnlineModel, scoreboard: Scoreboard)
    case answer(gameId: String, common: DrawGuessCommonOnlineModel, correctPlayer: Player, scoreboard: Scoreboard)
}

struct PlayScreenView: View {
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
            case .ready(let gameId, let playersReady):
                return AnyView(ReadyScreenView(viewModel: ReadyScreenViewModel(gameId: gameId,
                                                                               playersReady: playersReady)))
            case .guess(let gameId, let common, let scoreboard):
                return AnyView(
                    DrawScreenView(
                        viewModel: DrawScreenViewModel(
                            onlineModel: DrawScreenOnlineModel(
                                common: common))))
            case .answer(let gameId, let common, let correctPlayer, let scoreboard):
                return AnyView(Text("TODO"))
            }
        case .failure(let error):
            return AnyView(Text("Loading: \(error.localizedDescription)"))
        }
    }
}
