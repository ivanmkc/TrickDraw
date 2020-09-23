//
//  Constants.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-22.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct GlobalConstants {
    static let GoogleBot = Player(id: "ai", name: "GoogleBot")
    
    struct Colors {
        static let Primary = UIColor(hex: "5468FF")!
        static let PrimaryDarkened = UIColor(hex: "3D56F0")!
        static let Secondary = UIColor(hex: "00D9CD")!
        static let SecondaryDarkened = UIColor(hex: "19C4BA")!

        static let LightPurple = UIColor(hex: "E4E9FF")!
        static let LightPurple2 = UIColor(hex: "6A7FFF")!
        static let LightGrey = UIColor(hex: "F3F5F9")!
        static let Grey = UIColor(hex: "D4DCE7")!
        static let DarkGrey = UIColor(hex: "344356")!
        static let Teal = UIColor(hex: "00D9CD")!
        static let Red = UIColor(hex: "FD4755")!
        
        static let ShadowColor = UIColor(hex: "3C80D1")!.withAlphaComponent(0.09)
    }
    
    struct Fonts {
        static let Regular = Font.custom("Avenir-Regular", size: 16)
        static let Medium = Font.custom("Avenir-Medium", size: 20)
        static let Heavy = Font.custom("Avenir-Heavy", size: 20)
    }
    
    struct Game {
        static let GuessCooldownInSeconds: Double = 3
    }
}
