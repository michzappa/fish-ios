//
//  GameViewController.swift
//  Fish
//
//  Created by Michael Zappa on 7/30/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    let session = URLSession.shared
    
    @IBOutlet weak var RoomNameLabel: UILabel!
    @IBOutlet weak var PlayerNameLabel: UILabel!
    @IBOutlet weak var HandLabel: UILabel!
    @IBOutlet weak var TeamScoreLabel: UILabel!
    @IBOutlet weak var TeammatesLabel: UILabel!
    @IBOutlet weak var OpponentScoreLabel: UILabel!
    @IBOutlet weak var OpponentsLabel: UILabel!
    @IBOutlet weak var LastMoveLabel: UILabel!
    @IBOutlet weak var CurrentTurnLabel: UILabel!
    
    var player: Player? = nil;
    var roomName: String? = nil;
    var room: Room? = nil;
    var team: Team? = nil;
    var teammates: [Player]? = nil;
    var opponentTeam: Team? = nil;
    var opponents: [Player]? = nil;
    
    var refreshTimer: Timer?
    
    override func viewDidLoad() {
        // refresh from server
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            self.refreshTeamState()
            self.TeammatesLabel.text = "Teammates: \(self.makeNameString(players: self.teammates ?? []))"
            self.TeamScoreLabel.text = "Score: \(self.team?.claims.count ?? 0)"
            
            self.refreshOpponentState()
            self.OpponentScoreLabel.text = "Score: \(self.opponentTeam?.claims.count ?? 0)"
            self.OpponentsLabel.text = "Opponents: \(self.makeNameString(players: self.opponents ?? []))"
            
            self.refreshRoomStruct()
            self.LastMoveLabel.text = "Last Move: \(self.room?.move ?? "")"
            self.CurrentTurnLabel.text = "Turn: \(self.room?.turn ?? "")"
        }
        
        self.RoomNameLabel.text = "Room: \(self.roomName!)"
        self.PlayerNameLabel.text = "Player: \(self.player!.name)"
        self.HandLabel.text = "Hand:\n\(self.makeStringOfHand())"
        
        self.refreshTeamState()
        self.TeamScoreLabel.text = "Score: \(self.team?.claims.count ?? 0)"
        self.TeammatesLabel.text = "Teammates: \(self.makeNameString(players: self.teammates ?? []))"
        
        self.refreshOpponentState()
        self.OpponentScoreLabel.text = "Score: \(self.opponentTeam?.claims.count ?? 0)"
        self.OpponentsLabel.text = "Opponents: \(self.makeNameString(players: self.opponents ?? []))"
        
        self.LastMoveLabel.text = "Last Move: \(self.room?.move ?? "")"
        self.CurrentTurnLabel.text = "Turn: \(self.room?.turn ?? "")"
        super.viewDidLoad()
    }
    
    // GETs the room struct from the server
    func refreshRoomStruct(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/rooms/\(self.player!.room_id)")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let room: Room = try! JSONDecoder().decode(Room.self, from: data)
            print(room)
            self.room = room
        }
        
        task.resume()
    }
    
    // GETs the team structs and team members from the server
    func refreshTeamState(){
        self.refreshTeamStruct()
        self.refreshTeammates()
    }
    
    func refreshTeamStruct(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/teams/\(self.player!.team_id)")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let team: Team = try! JSONDecoder().decode(Team.self, from: data)
            print(team)
            self.team = team
        }
        
        task.resume()
    }
    
    func refreshTeammates(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/teams/\(self.player!.team_id)/players")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let players: [Player] = try! JSONDecoder().decode([Player].self, from: data)
            print(players)
            self.teammates = players
        }
        
        task.resume()
    }
    
    func refreshOpponentState(){
        var opponentTeamId: Int;
        if self.player!.team_id % 2 == 0 {
            opponentTeamId = self.player!.team_id - 1
        }
        else {
            opponentTeamId = self.player!.team_id + 1
        }
        
        refreshOpponentTeamStruct(id: opponentTeamId)
        refreshOpponents(id: opponentTeamId)
    }
    
    func refreshOpponentTeamStruct(id: Int){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/teams/\(id)")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let team: Team = try! JSONDecoder().decode(Team.self, from: data)
            print(team)
            self.opponentTeam = team
        }
        
        task.resume()
    }
    
    func refreshOpponents(id: Int){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/teams/\(id)/players")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let players: [Player] = try! JSONDecoder().decode([Player].self, from: data)
            print(players)
            self.opponents = players
        }
        
        task.resume()
    }
    
    // converts the given list of players into a string of their names
    func makeNameString(players: [Player])->String{
        let playerNames: [String] = players.map({ (player)->String in
            return player.name
        })
        
        return playerNames.joined(separator: ", ")
    }
    
    // converts the list of Strings which is the player's hand into a single string for display
    func makeStringOfHand()->String{
        return self.player!.hand.joined(separator: ", ")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
