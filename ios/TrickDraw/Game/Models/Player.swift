//
//  Player.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-19.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseFirestoreSwift

struct Player: Identifiable, Codable {
    let id: String
    let name: String
}

extension Player: Hashable {
    
}
