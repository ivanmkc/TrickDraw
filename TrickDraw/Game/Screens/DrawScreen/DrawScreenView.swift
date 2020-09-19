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
                              delegate: viewModel)
        }
    }
}

struct DrawScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DrawScreenView(
            viewModel: DrawScreenViewModel(
                onlineModel: DrawScreenOnlineModel(
                    common: DrawGuessCommonOnlineModel(
                        artist: Player.player1,
                        guessers: [],
                        question: "duck",
                        endTime: Date().addingTimeInterval(60),
                        guesses: [
                            (Player.player2, "toast"),
                            (Player.player3, "bread"),
                        ])
                )
            )
        )
    }
}

struct MyCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    weak var delegate: PKCanvasViewDelegate?
    
    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.tool = PKInkingTool(.pencil, color: .black, width: 5) // This color inverts depending on light vs dark mode
        canvasView.delegate = delegate
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}

