//
//  GuessScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-17.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import PencilKit

struct GuessScreenOnlineModel {
    let common: DrawGuessCommonOnlineModel
    
    let drawing: PKDrawing
    
    // Actions: Add guess
    func guessByAI(guess: String) {
        
    }
    
    func updateDrawing(drawing: PKDrawing) {
        let drawingAsString = String(data: drawing.dataRepresentation(), encoding: .utf8)
    }
}
struct GuessScreenViewModel {
    
    let name: String
    let players: [Player]
    
    func submitGuess(string: String) {
        
    }
}

struct GuessScreenView: View {
    @State private var canvasView = PKCanvasView()
    
    let viewModel: GuessScreenViewModel
    
    var body: some View {
        VStack {
            // Nav bar
            HStack(spacing: 10) {
                ForEach(viewModel.players, id: \.id) {
                    Text($0.name)
                }
            }
            
            // Canvas
            CanvasViewWrapper(canvasView: $canvasView,
                              delegate: nil)
        }
    }
}
