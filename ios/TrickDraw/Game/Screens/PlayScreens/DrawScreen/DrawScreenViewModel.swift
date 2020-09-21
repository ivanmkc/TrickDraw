//
//  DrawScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import PencilKit

class DrawScreenViewModel: NSObject, PKCanvasViewDelegate {
    // Server
    let onlineModel: DrawScreenOnlineModel? // TODO: Wrap in result?
    
    // Local
    var aiWarnings: String? = nil
    
    // TODO: Inject this
    let handler = QuickDrawModelDataHandler()!
    
    init(onlineModel: DrawScreenOnlineModel?) {
        self.onlineModel = onlineModel
        
        // TODO: Download online model
    }
    
    func handleDrawing() {
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Update the drawing on the server
            self.onlineModel?.updateDrawing(drawing: canvasView.drawing)
            
            // Perform inference
            let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1)
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let `self` = self else { return }
                
                guard let result = self.handler.runModel(input: image) else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    
                    switch (result) {
                    case .success(let guess):
                        self.onlineModel?.guessByAI(guess: guess)
                    //                        if guess == self.question {
                    //                            // TODO: Update the server that the AI has won
                    //
                    //                        } else {
                    //                            // TODO: Update the UI to warn the user that the AI is close
                    //                            guessByAI(guessFromAI)
                    //                        }
                    case .failure(let error):
                        print(error) // TODO: Show poptart
                    }
                }
            }
        }
        
    }
}
