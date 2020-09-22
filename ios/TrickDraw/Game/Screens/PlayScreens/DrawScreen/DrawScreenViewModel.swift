//
//  DrawScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import PencilKit

class DrawScreenViewModel: NSObject, ObservableObject {
    private let gameApi: GameAPI = DefaultGameAPI.shared
    
    // This is needed to prevent race condition crashes during inference.
    private let serialQueue = DispatchQueue(label: "inference")
    
    private let gameId: String
    @Published var onlineInfo: PlayGuessInfo
    @Published var drawing: PKDrawing?
    
    // Local
    var aiWarnings: String? = nil
    
    // TODO: Inject this
    private let handler = QuickDrawModelDataHandler()!
    
    init(gameId: String,
         onlineInfo: PlayGuessInfo) {
        self.gameId = gameId
        self.onlineInfo = onlineInfo
        
        if let drawingAsBase64 = onlineInfo.drawingAsBase64 {
            self.drawing = try? PKDrawing(base64Encoded: drawingAsBase64)
        }
    }
    
    private func submitGuessByAI(_ guess: String) {
        gameApi.submitGuessByAI(gameId, guess: guess) { (result) in
            switch (result) {
            case .success():
                break
            case .failure(let error):
                // Show poptart
                break
            }
        }
    }
}

extension DrawScreenViewModel: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        
        print("canvasViewDrawingDidChange")
        
        
        // Update the drawing on the server
        // TODO: Fix issue where the Firestore update sets the drawing on each artist update
        self.gameApi.updateDrawing(self.gameId, drawing: canvasView.drawing, nil) // TODO: Handle error
        
        // Perform inference
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1)
        
        serialQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            guard let result = self.handler.runModel(input: image) else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                
                switch (result) {
                case .success(let guess):
                    self.submitGuessByAI(guess)
                case .failure(let error):
                    print(error) // TODO: Show poptart
                }
            }
        }
    }
    
}
