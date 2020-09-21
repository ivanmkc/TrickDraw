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
        return AnyView(createView())
    }
    
    private func createView() -> AnyView {
        switch viewModel.stateInfo {
        case .loading:
            return AnyView(Text("Loading..."))
        case .success(let playState):
            switch playState {
            case .ready(let info):
                return AnyView(ReadyScreenView(viewModel: ReadyScreenViewModel(gameId: viewModel.gameId,
                                                                               hostPlayerId: viewModel.hostPlayerId,
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
