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
                .frame(height: 60)
        } else {
            Spacer()
                .frame(height: 60)
        }
    }
    
    private func createGuessText(_ guess: Guess) -> Text {
        let isBot = guess.playerId == GlobalConstants.GoogleBot.id
        
        if isBot {
            let text = guess.guess != "Unknown" ? "'\(guess.playerName)' guesses '\(guess.guess)' with \(String(format: "%.0f", guess.confidence  * 100))% confidence" : ""
            return Text(text)
                .foregroundColor(Color(GlobalConstants.Colors.Teal))
        } else {
            return Text("'\(guess.playerName)' guesses \(guess.guess)")
                .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
        }
    }
}
