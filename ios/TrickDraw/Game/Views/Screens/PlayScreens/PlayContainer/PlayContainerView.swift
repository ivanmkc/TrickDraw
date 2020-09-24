//
//  PlayScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct PlayContainerView: View {
    @ObservedObject
    var viewModel: PlayContainerViewModel
    
    var body: some View {
        ZStack {
            Color(GlobalConstants.Colors.LightGrey).edgesIgnoringSafeArea(.all)

            createView()
        }
        .animation(.default)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(Color(GlobalConstants.Colors.LightGrey))
    }
    
    private func createView() -> AnyView {
        switch viewModel.stateInfo {
        case .loading:
            return AnyView(
                Text("loading...")
                    .font(GlobalConstants.Fonts.Medium)
                    .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
            )
        case .success(let playState):
            switch playState {
            case .ready(let info):
                return AnyView(ReadyScreenView(viewModel: ReadyScreenViewModel(gameId: viewModel.gameId,
                                                                               hostPlayerId: viewModel.hostPlayerId,
                                                                               players: viewModel.players,
                                                                               playerIdsReady: info.playerIdsReady)))
            case .guess(let info):
                return AnyView(
                    viewModel.isHost ?
                        AnyView(
                            DrawScreenView(
                                viewModel:
                                    DrawScreenViewModel(
                                        gameId: viewModel.gameId,
                                        players: viewModel.players,
                                        scoreboard: viewModel.scoreboard,
                                        onlineInfo: info))
                        ):
                        AnyView(
                            GuessScreenView(
                                viewModel: GuessScreenViewModel(
                                    gameId: viewModel.gameId,
                                    scoreboard: viewModel.scoreboard,
                                    onlineInfo: info))
                        )
                )
            case .answer(let info):
                return AnyView(Text("TODO"))
            }
        case .failure(let error):
            return AnyView(Text("Loading: \(error.localizedDescription)"))
        }
    }
}

struct PlayContainerView_Previews: PreviewProvider {
    static var previews: some View {
        // Loading
        PlayContainerView(viewModel: PlayContainerViewModel(gameId: "GameId",
                                                            hostPlayerId: "PlayerId",
                                                            players: [Player.player1, Player.player2],
                                                            state: GameState.ready))
    }
}
