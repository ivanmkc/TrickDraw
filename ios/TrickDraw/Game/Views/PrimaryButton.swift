//
//  PrimaryButton.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-23.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI

struct PrimaryButton: View {
    
    struct Style {
        static let Purple = Style(
            backgroundColor: GlobalConstants.Colors.Primary,
            iconBackgroundColor: GlobalConstants.Colors.PrimaryDarkened)
        
        static let Green = Style(
            backgroundColor: GlobalConstants.Colors.Secondary,
            iconBackgroundColor: GlobalConstants.Colors.SecondaryDarkened)
        
        static let Disabled = Style(
            backgroundColor: GlobalConstants.Colors.Grey,
            iconBackgroundColor: GlobalConstants.Colors.DarkGrey.withAlphaComponent(0.3))

        
        let backgroundColor: UIColor
        let iconBackgroundColor: UIColor
    }
    
    private struct LocalConstants {
        struct Colors {
            static let TextFont = GlobalConstants.Fonts.Heavy
            static let Text = GlobalConstants.Colors.LightGrey
        }
    }
    
    let text: String?
    let shouldExpand: Bool
    var style: Style = Style.Green
    var systemImageName: String? = nil
    var isDisabled = false
    let action: () -> ()
    
    private var shadowColor: Color {
        return isDisabled ? Color.clear : Color(style.backgroundColor.withAlphaComponent(0.4))
    }
    
    var body: some View {
        // TODO: style button
        Button(action: action) {
            HStack(spacing: 15) {
                
                if shouldExpand { Spacer() }
                
                if let text = text {
                    Text(text)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .font(LocalConstants.Colors.TextFont)
                        .padding([.leading], systemImageName == nil ? 0 : 30)
                        .multilineTextAlignment(.center)
                }
                                
                if shouldExpand { Spacer() }
                
                if let systemImageName = systemImageName {
                    Image(systemName: systemImageName) // TODO: Use actual logo
                        .resizable()
                        .foregroundColor(.white)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(10)
                        .frame(width: 35, alignment: .center)
                        .background(isDisabled ? Color(Style.Disabled.iconBackgroundColor) : Color(style.iconBackgroundColor))
                        .font(.title)
                        .clipShape(Circle())
                }
            }
            .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14))
            .frame(height: 65)
            .foregroundColor(.white)
            .background(isDisabled ? Color(Style.Disabled.backgroundColor) : Color(style.backgroundColor))
            .cornerRadius(10)
            .shadow(color: shadowColor, radius: 25, x: 0, y: 10)
        }
        .disabled(isDisabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrimaryButton(text: "REPLAY",
                          shouldExpand: false) {
                print("Button Tapped!")
            }
            
            PrimaryButton(text: "REPLAY",
                          shouldExpand: true) {
                print("Button Tapped!")
            }
            
            PrimaryButton(text: "REPLAY",
                          shouldExpand: true,
                          style: .Green) {
                print("Button Tapped!")
            }
            
            PrimaryButton(text: nil,
                          shouldExpand: false,
                          systemImageName: "questionmark") {
                
            }
            
            PrimaryButton(text: nil,
                          shouldExpand: false,
                          systemImageName: "trash") {
                
            }
            
            PrimaryButton(text: nil,
                          shouldExpand: false,
                          style: .Disabled,
                          systemImageName: "trash") {
                
            }
        }
    }
}
