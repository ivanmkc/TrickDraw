//
//  LobbyScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct LobbyScreenView: View {
    @ObservedObject var viewModel: LobbyScreenViewModel
    @State var selectedGameId: String?
    
    init(viewModel: LobbyScreenViewModel) {
        self.viewModel = viewModel
        
        setupNavigationAppearance()
        setupTableAppearance()
    }
    
    private func setupNavigationAppearance() {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = GlobalConstants.Colors.LightGrey
        coloredAppearance.titleTextAttributes = [.foregroundColor : GlobalConstants.Colors.LightPurple2]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor : GlobalConstants.Colors.LightPurple2]
        coloredAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    private func setupTableAppearance() {
        // To remove all separators including the actual ones:
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(GlobalConstants.Colors.LightGrey).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    viewModel.games.isEmpty ?
                        AnyView(
                            Text("No games found :(")
                                .font(GlobalConstants.Fonts.Heavy)
                                .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
                        ) :
                        AnyView(
                            ScrollView {
                                VStack(spacing: 15) {
                                    ForEach(viewModel.games) { game in
                                        // TODO: Join game
                                        NavigationLink(
                                            destination: PlayContainerView(
                                                viewModel: PlayContainerViewModel(gameId: game.id!,
                                                                                  hostPlayerId: game.hostPlayerId,
                                                                                  players: game.players,
                                                                                  state: game.state)),
                                            tag: game.id!,
                                            selection: $selectedGameId) {
                                            HStack {
                                                Text(game.name)
                                                    .font(GlobalConstants.Fonts.Heavy)
                                                    .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
                                                Spacer()
                                                Text("\(game.players.count) players")
                                                    .font(GlobalConstants.Fonts.Regular)
                                                    .foregroundColor(Color(GlobalConstants.Colors.LightPurple2))
                                            }
                                            .padding(20)
                                            .frame(height: 60)
                                            .onTapGesture {
                                                viewModel.joinGame(game.id!) { _ in
                                                    selectedGameId = game.id!
                                                }
                                            }
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                            }
                        )
                    
                    Spacer()
                    
                    HStack {
                        PrimaryButton(text: "New game",
                                      shouldExpand: true,
                                      systemImageName: "plus") {
                            viewModel.createGame { result in
                                switch (result) {
                                case .success(let gameId):
                                    selectedGameId = gameId
                                case .failure:
                                    // TODO: Show error toast
                                    break
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color(GlobalConstants.Colors.LightGrey))
                .navigationBarTitle("Lobby")
            }
            .animation(.default)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(GlobalConstants.Colors.LightPurple2))
    }
}

struct LobbyScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyScreenView(viewModel: LobbyScreenViewModel())
    }
}


