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
    @State var isCoolingDown = false
    
    let viewModel: GuessScreenViewModel
    
    init(viewModel: GuessScreenViewModel) {
        self.viewModel = viewModel
    }
    
    private func scaledDrawing(_ drawing: PKDrawing, size: CGSize) -> PKDrawing {
        let scaleFactor = min(size.width/drawing.bounds.size.width, size.height/drawing.bounds.size.height)
        let newDrawing = drawing
            .transformed(using: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))

        return newDrawing
            .transformed(using: CGAffineTransform(translationX: -newDrawing.bounds.origin.x,
                                                  y: -newDrawing.bounds.origin.y))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScoreboardView(scoreboard: viewModel.scoreboard)
                        
            if let correctGuess =
                viewModel.onlineInfo.guesses.first { $0.isCorrect } {
                // Drawing instructions
                Text("'\(correctGuess.playerName)' wins!")
                    .foregroundColor(Color(GlobalConstants.Colors.Teal))
                    .font(GlobalConstants.Fonts.Medium)
                    .frame(height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            
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
            
            VStack(spacing: 10) {
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
                                          isDisabled: isCoolingDown || viewModel.onlineInfo.isFinished) {
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
        .navigationBarTitle(Text("\(viewModel.onlineInfo.artist.name) is drawing"), displayMode: .inline)
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
                                            scoreboard: [
                                                Player.player1.id: 10,
                                                Player.player2.id: 20,
                                                GlobalConstants.GoogleBot.id: 40
                                            ],
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
                                                                      drawingAsBase64: nil
                                            )
            )
        )
    }
}

