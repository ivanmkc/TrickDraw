//
//  DrawScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import PencilKit

class DrawScreenViewModel: NSObject, ObservableObject {
    struct Constants {
        static let confidenceThreshold: Float = 0.3
    }
    
    private let gameApi: GameAPI = DefaultGameAPI.shared
    
    // This is needed to prevent race condition crashes during inference.
    private let serialQueue = DispatchQueue(label: "inference")
    
    private let gameId: String
    @Published var onlineInfo: PlayGuessInfo
    @Published var drawing: PKDrawing?
    
    // Local
    var aiWarnings: String? = nil
    
    // TODO: Inject this
    private let handler = QuickDrawModelDataHandler.shared
    
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
                // Show error toast
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
            
            let result = self.handler.runModel(input: image)
            
            switch (result) {
            case .success(let guesses):
                if let bestGuess = guesses.first, bestGuess.confidence > Constants.confidenceThreshold {
                    self.submitGuessByAI(bestGuess.guess)
                } else {
                    self.submitGuessByAI("Unknown")
                }
            case .failure(let error):
                print(error) // Show error toast
            }
        }
    }
    
}
