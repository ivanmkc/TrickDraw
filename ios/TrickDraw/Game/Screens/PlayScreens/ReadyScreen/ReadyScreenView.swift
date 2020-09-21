//
//  ReadyScreen.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct ReadyScreenView: View {
    @ObservedObject
    var viewModel: ReadyScreenViewModel
    
    var body: some View {
        VStack {
            Text("Ready")
            HStack {
                ForEach(viewModel.players, id: \.self.id) { (player) in
                    VStack {
                        Text(player.name)
                        Text(viewModel.playerIdsReady.contains(player.id) ? "READY" : "NOT READY")
                    }
                }
            }
            
            Button("Ready up!") {
                viewModel.readyUp()
            }
            
            if viewModel.isHost {
                Button("Start game") {
                    viewModel.startGame()
                }
            }
        }
    }
}

struct ReadyScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyScreenView(viewModel: ReadyScreenViewModel(gameId: "ASDF",
                                                        hostPlayerId: "randomID",
                                                        players: [Player.player1, Player.player2], playerIdsReady: [Player.player1.id]))
    }
}

