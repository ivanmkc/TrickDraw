//
//  LobbyScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct LobbyScreenView: View {
    @ObservedObject
    var viewModel: LobbyScreenViewModel
    
    var body: some View {
        NavigationView {
            
            VStack {
                Text("Lobby")
                    
                viewModel.games.isEmpty ?
                    AnyView(Text("No games found")) :
                    AnyView(
                        List(viewModel.games) { game in
                            // TODO: Join game
                            NavigationLink(
                                destination: PlayContainerView(
                                    viewModel: PlayContainerViewModel(gameId: game.id!,
                                                                      hostPlayerId: game.hostPlayerId,
                                                                      players: game.players,
                                                                      state: game.state))) {
                                HStack {
                                    Text(game.name)
                                    Spacer()
                                    Text("\(game.players.count) players")
                                }
                                .frame(height: 60)
                                .onTapGesture {
                                    viewModel.joinGame(game.id!)
                                }
                            }
                        }
                    )
                
                HStack {
                    Button("New") {
                        viewModel.createGame()
                    }
                    
                    Button("Join") {
                        
                    }
                }
            }
        }
    }
}

struct LobbyScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyScreenView(viewModel: LobbyScreenViewModel())
    }
}


