//
//  DrawScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import PencilKit

class DrawScreenViewModel: NSObject, ObservableObject {
    // Server
    private let gameApi: GameAPI = DefaultGameAPI.shared
    
    private let gameId: String
    @Published var onlineInfo: PlayingGuessInfo
    
    // Local
    var aiWarnings: String? = nil
    
    // TODO: Inject this
    private let handler = QuickDrawModelDataHandler()!
    
    init(gameId: String,
         onlineInfo: PlayingGuessInfo) {
        self.gameId = gameId
        self.onlineInfo = onlineInfo
    }
}

extension DrawScreenViewModel: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print("canvasViewDrawingDidChange")
        
        // Update the drawing on the server
        self.gameApi.updateDrawing(self.gameId, drawing: canvasView.drawing, nil) // TODO: Handle error
        
        // Perform inference
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1)

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }

            guard let result = self.handler.runModel(input: image) else { return }

            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }

                switch (result) {
                case .success(let guess):
                    break
                // self.guessByAI(guess: guess)
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

extension DrawScreenViewModel {
    var drawing: PKDrawing? {
        if let drawingData = onlineInfo.drawingAsBase64?.data(using: .utf8) {
            return try? PKDrawing(data: drawingData)
        } else {
            return nil
        }
    }
}
