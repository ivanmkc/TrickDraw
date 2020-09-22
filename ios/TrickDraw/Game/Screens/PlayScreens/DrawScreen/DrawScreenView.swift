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
            Button("Clear") {
                self.canvasView.drawing = PKDrawing()
            }
            Button("Undo") {
                self.undoManager?.undo()
            }
            Button("Redo") {
                self.undoManager?.redo()
            }
            
            CanvasViewWrapper(canvasView: $canvasView,
                              delegate: self.viewModel)
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

