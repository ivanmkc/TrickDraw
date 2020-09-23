//
//  UIColor+hex.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-23.
//  Copyright © 2020 Google. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1) {
        if (hex.starts(with: "#")) { hex.dropFirst() }
        
        guard hex.count == 6 else {
            return nil
        }
        
        let chars = Array(hex)
        self.init(red:   .init(strtoul(String(chars[0...1]),nil,16))/255,
                  green: .init(strtoul(String(chars[2...3]),nil,16))/255,
                  blue:  .init(strtoul(String(chars[4...5]),nil,16))/255,
                  alpha: alpha)}
}

