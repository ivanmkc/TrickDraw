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
        VStack(spacing: 10) {
            HStack {
                Button("Clear") {
                    self.canvasView.drawing = PKDrawing()
                }
                Button("Undo") {
                    self.undoManager?.undo()
                }
                Button("Redo") {
                    self.undoManager?.redo()
                }
            }
            
            Button("Reset") { viewModel.resetRound() }
            
            Text("Draw '\(viewModel.onlineInfo.question)'!")
            
            CanvasViewWrapper(canvasView: $canvasView,
                              isUserInteractionEnabled: true,
                              drawing: viewModel.drawing,
                              shouldUpdateDrawing: false,
                              delegate: self.viewModel)
                .environment(\.colorScheme, .dark)
            
            viewModel
                .onlineInfo
                .guesses
                .last
                .map { (guess) in
                    guess.playerId == GlobalConstants.GoogleBot.id ?
                        Text("'\(guess.playerName)' guesses \(guess.guess) with confidence \(String(format: "%.1f", guess.confidence))")
                        .foregroundColor(Color.white) :
                        Text("'\(guess.playerName)' guesses \(guess.guess)")
                        .foregroundColor(Color.white)
                }
                .animation(.easeInOut(duration: 1))
        }
    }
}

//struct DrawScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        DrawScreenView(
//            viewModel: DrawScreenViewModel(
//                artist: Player.player1,
//                guessers: [],
//                question: "duck",
//                endTime: Date().addingTimeInterval(60),
//                guesses: [
//                    Guess(playerId: Player.player2.id, guess: "toast"),
//                    Guess(playerId: Player.player3.id, guess: "bread"),
//                ],
//                drawingAsBase64: nil)
//        )
//    }
//}

