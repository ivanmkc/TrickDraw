//
//  GuessScreenView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-17.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import PencilKit

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
            ZStack {
                CanvasViewWrapper(canvasView: $canvasView,
                                  isUserInteractionEnabled: false,
                                  drawing: viewModel.drawing,
                                  shouldUpdateDrawing: true)
                    .environment(\.colorScheme, .dark)
                
                VStack {
                    Spacer()
                    
                    viewModel
                        .onlineInfo
                        .guesses
                        .last
                        .map {
                            Text("'\($0.playerName)' guesses \($0.guess)")
                                .foregroundColor(Color.white)
                        }
                        .animation(.easeInOut(duration: 1))
                }
            }

            VStack {
                ForEach(Array(viewModel
                                .onlineInfo
                                .choices
                                .chunked(by: 2)
                                .enumerated()), id: \.offset) { (offset, element) in
                    HStack {
                        ForEach(Array(element.enumerated()), id: \.offset) { (offset, choice) in
                            Spacer()
                            Button(choice) {
                                viewModel.submitGuess(guess: choice)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0 ..< Swift.min($0 + chunkSize, self.count)]) // fixed
        }
    }
}
