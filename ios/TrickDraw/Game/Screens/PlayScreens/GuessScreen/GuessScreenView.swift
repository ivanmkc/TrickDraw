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
//    let drawing: PKDrawing
    
    // Actions: Add guess
    func guessByAI(guess: String) {
        
    }
}

class GuessScreenViewModel: NSObject, ObservableObject {
    // Server
    private let gameApi: GameAPI = DefaultGameAPI.shared
    
    private let gameId: String
    @Published var onlineInfo: PlayingGuessInfo
    @Published var drawing: PKDrawing?
    
    // Local
    var aiWarnings: String? = nil
    
    init(gameId: String,
         onlineInfo: PlayingGuessInfo) {
        self.gameId = gameId
        self.onlineInfo = onlineInfo
        
        if let drawingAsBase64 = onlineInfo.drawingAsBase64 {
            self.drawing = try? PKDrawing(base64Encoded: drawingAsBase64)
        }
    }
}

struct GuessScreenView: View {
    @State private var canvasView = PKCanvasView()
    
    let viewModel: GuessScreenViewModel
    
    var body: some View {
        VStack {
            // Nav bar
            Text("Guess the drawing!")
//            HStack(spacing: 10) {
//                ForEach(viewModel.players, id: \.id) {
//                    Text($0.name)
//                }
//            }
//            
            // Canvas
            CanvasViewWrapper(canvasView: $canvasView,
                              isUserInteractionEnabled: false,
                              initialDrawing: viewModel.drawing)
                .environment(\.colorScheme, .dark)
        }
    }
}
