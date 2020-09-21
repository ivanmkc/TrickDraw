//
//  DrawGuessCommonOnlineViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import Foundation
import PencilKit

struct Guess: Codable {
    let playerId: String
    let guess: String
}
