//
//  Scoreboard.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-23.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct ScoreboardEntry: View {
    let text: String
    let image: UIImage
    let score: Int
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)

                Text(text)
                    .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
                    .font(GlobalConstants.Fonts.Heavy)
            }
            

            Text("\(score)")
                .foregroundColor(Color(GlobalConstants.Colors.DarkGrey))
                .font(GlobalConstants.Fonts.Medium)
                .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .background(Color(GlobalConstants.Colors.Grey))
                .cornerRadius(5)
        }
    }
}

struct ScoreboardView: View {
    
    let scoreboard: Scoreboard
    
    private var botScore: Int {
        scoreboard
            .filter { $0.key == GlobalConstants.GoogleBot.id }
            .reduce(0) { $0 + $1.value}
    }
    
    private var humanScore: Int {
        scoreboard
            .filter { $0.key != GlobalConstants.GoogleBot.id }
            .reduce(0) { $0 + $1.value}
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ScoreboardEntry(text: "GoogleBot", image: UIImage(named: "cloudml")!, score: botScore)
            
            Divider()
            
            ScoreboardEntry(text: "Humans", image: UIImage(systemName: "person.3.fill")!, score: humanScore)
        }
        .frame(height: 80)
    }
}
