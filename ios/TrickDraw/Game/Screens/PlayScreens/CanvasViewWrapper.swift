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
    var drawing: PKDrawing? = nil
    var shouldUpdateDrawing: Bool = false
    
    weak var delegate: PKCanvasViewDelegate? {
        didSet {
            canvasView.delegate = delegate
        }
    }
        
    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.tool = PKInkingTool(.pencil, color: .black, width: 5) // This color inverts depending on light vs dark mode
        if let drawing = drawing {
            canvasView.drawing = drawing
        }
        
        return canvasView
    }
        
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if let drawing = drawing, shouldUpdateDrawing {
            canvasView.drawing = drawing
        }
        
        canvasView.isUserInteractionEnabled = isUserInteractionEnabled
        canvasView.delegate = delegate
    }
}
