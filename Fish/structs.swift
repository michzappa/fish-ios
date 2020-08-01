//
//  structs.swift
//  Fish
//
//  Created by Michael Zappa on 7/30/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

import Foundation

struct Room: Decodable {
    let id: Int
    let move: String
    let name: String
    let turn: String
}

struct Player: Decodable {
    let hand: [String]
    let id: Int
    let name: String
    let room_id: Int
    let team_id: Int
}

struct Team: Decodable {
    let id: Int
    let claims: [String]
    let room_id: Int
}

struct CardsCanAskFor: Decodable {
    let can_ask_for: [String]
}

struct HalfSuit: Equatable {
    let name: String
    let id: Int
}

struct CardsInHalfSuit: Decodable {
    let cards: [String]
}
