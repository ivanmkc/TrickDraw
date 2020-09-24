//
//  GuessesView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-23.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct GuessesView: View {
    let guesses: [Guess]
    
    var body: some View {
        if let guess = guesses.last {
            createGuessText(guess)
                .multilineTextAlignment(.center)
                .font(GlobalConstants.Fonts.Medium)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 2,
                                dash: [15]
                            )
                        )
                        .foregroundColor(guess.isCorrect ? Color(GlobalConstants.Colors.Teal) : Color(GlobalConstants.Colors.DarkGrey))
                )
                .frame(height: 60)
        } else {
            Spacer()
                .frame(height: 60)
        }
    }
    
    private func createGuessText(_ guess: Guess) -> some View {
        let isBot = guess.playerId == GlobalConstants.GoogleBot.id
        
        if isBot {
            let text: String = "'\(guess.playerName)' guesses '\(guess.guess)' with \(String(format: "%.0f", guess.confidence  * 100))% confidence"

            return Text(text)
                .minimumScaleFactor(0.5)
                .foregroundColor(guess.isCorrect ? Color(GlobalConstants.Colors.Teal) : Color(GlobalConstants.Colors.DarkGrey))
        } else {
            return Text("'\(guess.playerName)' guesses \(guess.guess)")
                .minimumScaleFactor(0.5)
                .foregroundColor(guess.isCorrect ? Color(GlobalConstants.Colors.Teal) : Color(GlobalConstants.Colors.DarkGrey))
        }
    }
}
