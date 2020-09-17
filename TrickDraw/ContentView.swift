//
//  ContentView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-15.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    var body: some View {
        Writer()
            .environment(\.colorScheme, .dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Writer: View {
    @Environment(\.undoManager) var undoManager
    let inferenceManager = InferenceManager(handler: QuickDrawModelDataHandler()!)
    
    @State private var canvasView = PKCanvasView()

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
            MyCanvas(canvasView: $canvasView, inferenceManager: inferenceManager)
        }
    }
    
//    canvasView.drawing.image(from: imgRect, scale: 1.0)
}

struct MyCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var inferenceManager: InferenceManager?

    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.tool = PKInkingTool(.pencil, color: .black, width: 5) // This color inverts depending on light vs dark mode
        canvasView.delegate = inferenceManager
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}

class InferenceManager: NSObject, PKCanvasViewDelegate {
    let handler: QuickDrawModelDataHandler
    
    init(handler: QuickDrawModelDataHandler) {
        self.handler = handler
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 224/max(canvasView.bounds.size.height, canvasView.bounds.size.height))
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }

            let result = self.handler.runModel(input: image)
            
            DispatchQueue.main.async {
                print(result)
            }
        }
    }
}
