//
//  DrawScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-17.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import PencilKit

struct DrawScreenView: View {
    var viewModel: DrawScreenViewModel
    
    @Environment(\.undoManager) var undoManager
    @State private var canvasView = PKCanvasView()
        
    init(viewModel: DrawScreenViewModel) {
        self.viewModel = viewModel
        
        canvasView.delegate = viewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScoreboardView(scoreboard: viewModel.onlineInfo.scoreboard)
            
            Spacer()
            
            // Drawing instructions
            Text("Draw '\(viewModel.onlineInfo.question)'")
                .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
                .font(GlobalConstants.Fonts.Medium)
                .frame(height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            // Canvas
            CanvasViewWrapper(canvasView: $canvasView,
                              isUserInteractionEnabled: true,
                              drawing: viewModel.drawing,
                              shouldUpdateDrawing: false,
                              delegate: self.viewModel)
                .environment(\.colorScheme, .dark)
                .cornerRadius(20)
            
            // Drawing controls
            HStack {
                // Clear
                PrimaryButton(text: nil,
                              shouldExpand: false,
                              systemImageName: "trash") {
                    self.canvasView.drawing = PKDrawing()
                }
                
                // Undo
                PrimaryButton(text: nil,
                              shouldExpand: false,
                              systemImageName: "arrow.uturn.left") {
                    self.undoManager?.undo()
                }
                
                // Redo
                PrimaryButton(text: nil,
                              shouldExpand: false,
                              systemImageName: "arrow.uturn.right") {
                    self.undoManager?.redo()
                }
                
                Spacer()
                
                PrimaryButton(text: "Skip",
                              shouldExpand: false,
                              style: .Purple,
                              systemImageName: "chevron.right.2") {
                    viewModel.resetRound()
                    canvasView.drawing = PKDrawing()
                }
            }
            
            GuessesView(guesses: viewModel.onlineInfo.guesses)
        }
        .padding(20)
        .navigationBarTitle(Text("You are the artist"), displayMode: .inline)
    }
}

struct DrawScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DrawScreenView(
            viewModel: DrawScreenViewModel(gameId: "gameId",
                                           players: [Player.player1, Player.player2],
                                           onlineInfo: PlayGuessInfo(artist: Player.player1,
                                                                     guessers: [],
                                                                     question: "duck",
                                                                     choices: [], endTime: Date().addingTimeInterval(60),
                                                                     guesses: [
                                                                        Guess(playerId: Player.player1.id,
                                                                              playerName: Player.player1.name,
                                                                              guess: "toast", confidence: 1),
                                                                        Guess(playerId: Player.player2.id,
                                                                              playerName: Player.player2.name,
                                                                              guess: "bread",
                                                                              confidence: 1),
                                                                     ],
                                                                     drawingAsBase64: nil,
                                                                     scoreboard: [
                                                                        Player.player1.id: 10,
                                                                        Player.player2.id: 20,
                                                                        GlobalConstants.GoogleBot.id: 40
                                                                     ]
                                           )
            )
        )
    }
}

