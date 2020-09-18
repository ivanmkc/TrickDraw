//
//  DrawScreenOnlineViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestore
import PencilKit

struct DrawScreenOnlineModel {
    let common: DrawGuessCommonOnlineModel
    
    // Actions: Add guess
    func guessByAI(guess: String) {
        
    }
    
    func updateDrawing(drawing: PKDrawing) {
        let drawingAsString = String(data: drawing.dataRepresentation(), encoding: .utf8)
    }
}

//extension DrawScreenOnlineModel: FirestoreModel {
//    
//}
