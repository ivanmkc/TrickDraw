//
//  LobbyScreenViewModel.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-18.
//  Copyright © 2020 Google. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Game: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    
    let name: String
    var players: [Player] = []
    
    enum GameState {
        case ready
        case play
        case score
    }
}

//struct LobbyScreenOnlineModel: Identifiable, Codable {
//    @DocumentID var id: String? = UUID().uuidString
//
//    var games: [Game]
//
//    init?(document: QueryDocumentSnapshot) {
//      let data = document.data()
//
//      guard let name = data["games"] as? [String] else {
//        return nil
//      }
//
//      id = document.documentID
//      self.name = name
//    }
//}

class LobbyScreenViewModel: ObservableObject {
    private var database: Firestore = Firestore.firestore()
    private var gamesListener: ListenerRegistration?
    
    private var gamesReference: CollectionReference {
        return database.collection("games")
    }
    
    @Published var games: [Game] = []
    
    init() {
        setupListener()
    }
    
    func setupListener() {
        gamesListener = gamesReference.addSnapshotListener { querySnapshot, error in
            // TODO: Sort by creation date
            guard let documents = querySnapshot?.documents else {
                print("Error listening for games updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            self.games = documents.compactMap { queryDocumentSnapshot -> Game? in
                do {
                    return try queryDocumentSnapshot.data(as: Game.self)
                } catch (let error) {
                    print("Error serializing game: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
    
    func createGame() {
        do {
            guard let displayName = Auth.auth().currentUser?.displayName else { return }
            // TODO: Move to Cloud function to auto-assign name
            try gamesReference.addDocument(from: Game(name: "\(displayName)'s game",
                                                      players: []))
        } catch (let error) {
            print("Error creating game: \(error.localizedDescription)")
        }
    }
    
    deinit {
        gamesListener?.remove()
    }
}