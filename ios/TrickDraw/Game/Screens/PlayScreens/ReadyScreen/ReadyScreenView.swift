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
                ForEach(Array(viewModel.playersReady), id: \.self.key) { (player, isReady) in
                    VStack {
                        Text(player.name)
                        Text(isReady ? "READY" : "NOT READY")
                    }
                }
            }
            
            Button("Ready up!") {
                viewModel.readyUp()
            }
        }
    }
}

struct ReadyScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyScreenView(viewModel: ReadyScreenViewModel(gameId: "ASDF", playersReady: [Player.player1: true,
                                                                                       Player.player2 : false]))
    }
}

