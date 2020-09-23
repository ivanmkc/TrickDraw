//
//  GuessScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-17.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import PencilKit

struct GuessScreenView: View {
    @State private var canvasView = PKCanvasView()
    
    let viewModel: GuessScreenViewModel
    
    @State private var isCoolingDown = false
        
    init(viewModel: GuessScreenViewModel) {
        self.viewModel = viewModel
    }
    
    private func scaledDrawing(_ drawing: PKDrawing, size: CGSize) -> PKDrawing {
        let scaleFactor = min(size.width/drawing.bounds.size.width, size.height/drawing.bounds.size.height)
        return drawing.transformed(using: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScoreboardView(scoreboard: viewModel.onlineInfo.scoreboard)
            
            Spacer()
            
            // Drawing instructions
            Text("Guess what the drawing is!")
                .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
                .font(GlobalConstants.Fonts.Medium)
                .frame(height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            GeometryReader { geometry in
                // Canvas
                CanvasViewWrapper(canvasView: $canvasView,
                                  isUserInteractionEnabled: true,
                                  drawing: viewModel.drawing.map { scaledDrawing($0, size: geometry.size) },
                                  shouldUpdateDrawing: true)
                    .environment(\.colorScheme, .dark)
            }
            .cornerRadius(20)
            .aspectRatio(1, contentMode: .fit)
            
            GuessesView(guesses: viewModel.onlineInfo.guesses)
            
            Divider()
            
            VStack {
                ForEach(Array(viewModel
                                .onlineInfo
                                .choices
                                .chunked(by: 2)
                                .enumerated()), id: \.offset) { (offset, element) in
                    HStack {
                        ForEach(Array(element.enumerated()), id: \.offset) { (offset, choice) in
                            Spacer()
                            PrimaryButton(text: choice,
                                          shouldExpand: true,
                                          style: .Green,
                                          isDisabled: isCoolingDown) {
                                viewModel.submitGuess(guess: choice)
                                
                                isCoolingDown = true
                                
                                // Unblock questions
                                // TODO: Move to server-side
                                DispatchQueue.main.asyncAfter(deadline: .now() + GlobalConstants.Game.GuessCooldownInSeconds) {
                                    isCoolingDown = false
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(20)
        .navigationBarTitle(Text("\(viewModel.onlineInfo.artist.name) is the artist"), displayMode: .inline)
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0 ..< Swift.min($0 + chunkSize, self.count)]) // fixed
        }
    }
}

struct GuessScreenView_Previews: PreviewProvider {
    static var previews: some View {
        GuessScreenView(
            viewModel: GuessScreenViewModel(gameId: "gameId",
                                            onlineInfo: PlayGuessInfo(artist: Player.player1,
                                                                      guessers: [],
                                                                      question: "duck",
                                                                      choices: ["toast", "sheep", "duck", "faucet"], endTime: Date().addingTimeInterval(60),
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

