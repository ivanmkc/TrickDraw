//
//  CanvasView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-17.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import PencilKit

struct CanvasViewWrapper: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    var isUserInteractionEnabled: Bool = true
    var initialDrawing: PKDrawing? = nil
    
    weak var delegate: PKCanvasViewDelegate? {
        didSet {
            canvasView.delegate = delegate
        }
    }
        
    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.tool = PKInkingTool(.pencil, color: .black, width: 5) // This color inverts depending on light vs dark mode
        return canvasView
    }
    
    func setDrawing(drawing: PKDrawing) {
        canvasView.drawing = drawing
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if let initialDrawing = initialDrawing {
            canvasView.drawing = initialDrawing
        }
        
        canvasView.isUserInteractionEnabled = isUserInteractionEnabled
        canvasView.delegate = delegate
    }
}
