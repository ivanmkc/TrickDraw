//
//  AuthWrapperView.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import SwiftUI
import Firebase

class AuthWrapperViewModel: ObservableObject {
    var displayName: String = "" {
        didSet {
            isLoginButtonEnabled = !displayName.isEmpty
        }
    }
    
    @Published var isAuthenticated: Bool = false    
    @Published var isLoginButtonEnabled: Bool = false
    
    var authListener: AuthStateDidChangeListenerHandle?
    var auth: Auth?
    var user: User?
    
    init() {
        setupListeners()
    }
    
    private func setupListeners() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let `self` = self else { return }
            self.auth = auth
            self.user = user
            
            self.isAuthenticated = Auth.auth().currentUser != nil
        }
    }
    
    func login() {
        if !displayName.isEmpty {
            Auth.auth().signInAnonymously { [weak self] (result, error) in
                guard let `self` = self else { return }
                if let error = error {
                    // TODO: Show error
                    
                    print(error)
                }
                
                // Set user name
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.displayName
                changeRequest?.commitChanges { (error) in
                    // TODO: Show error
                    
                    print(error)
                }
            }
        }
    }
    
    deinit {
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
}

struct AuthWrapperView: View {
    @ObservedObject var viewModel: AuthWrapperViewModel
    
    let view: AnyView
    
    var body: some View {
        return viewModel.isAuthenticated ?
            view
            : AnyView(
                VStack {
                    TextField("Name", text: $viewModel.displayName)
                    Button("Log in") {
                        viewModel.login()
                    }
                    .disabled(!viewModel.isLoginButtonEnabled)
                }
            )
    }
}

struct AuthWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        AuthWrapperView(viewModel: AuthWrapperViewModel(),
                        view: AnyView(Text("Logged in!")))
    }
}
