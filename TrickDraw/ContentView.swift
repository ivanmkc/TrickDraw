//
//  ContentView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-15.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    var body: some View {
        DrawScreenView(viewModel: DrawScreenViewModel(onlineModel: nil))
            .environment(\.colorScheme, .dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
