//
//  GameViewController.swift
//  Fish
//
//  Created by Michael Zappa on 7/30/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
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
    @IBOutlet weak var SelectOpponentPicker: UIPickerView!
    @IBOutlet weak var SelectCardPicker: UIPickerView!
    @IBOutlet weak var AskForCardBtn: UIButton!
    
    var player: Player? = nil;
    var cardsCanAskFor: [String]? = nil;
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
            
            self.refreshInformation()
        }
        
        // UIPickerView setup
        self.SelectOpponentPicker.delegate = self
        self.SelectOpponentPicker.dataSource = self
        self.SelectCardPicker.delegate = self
        self.SelectCardPicker.dataSource = self
        
        self.AskForCardBtn.addTarget(self, action: #selector(askForCard), for: .touchDown)
        
        self.RoomNameLabel.text = "Room: \(self.roomName!)"
        self.PlayerNameLabel.text = "Player: \(self.player!.name)"
        
        self.refreshInformation()
        
        super.viewDidLoad()
    }

    // Sends PUT request to server to attempt to exchange cards between the game's player and the selected opponent.
    @objc func askForCard(){
        let selectedOpponentIndex = self.SelectOpponentPicker.selectedRow(inComponent: 0)
        let selectedOpponent = self.opponents![selectedOpponentIndex]
        
        let selectedCardIndex = self.SelectCardPicker.selectedRow(inComponent: 0)
        let selectedCard = self.cardsCanAskFor![selectedCardIndex]
        
        let url = URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/players")
        guard let requestUrl = url else { fatalError() }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
        
        let json: [String: Any] = ["asking_id": self.player!.id, "asked_id": selectedOpponent.id, "card": selectedCard, "room_id": self.room!.id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])

        let task = session.uploadTask(with: request, from: jsonData) { (data, response, error) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                    switch dataString.contains("error"){
                    //case "{\"error\":\"a cannot ask for 2-Hearts\"}":
                    case true:
                        print("Not your turn")
                    default:
                        print("Good ask")
                        
                    }
                }
        }
        task.resume()
    }
    
    // Picker with tag 1 is the select opponent picker
    func numberOfComponents(in pickerView: UIPickerView)->Int{
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int)->Int{
        if pickerView.tag == 1 {
            return self.opponents?.count ?? 0
        }
        if pickerView.tag == 2 {
            return self.cardsCanAskFor?.count ?? 0
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String?{
        if pickerView.tag == 1 {
            return self.opponents?[row].name ?? ""
        }
        if pickerView.tag == 2 {
            return self.cardsCanAskFor?[row] ?? ""
        }
        
        return "blank"
    }
    
    
    // refreshes the state of the displayed information
    func refreshInformation(){
        self.refreshTeamState()
        self.TeamScoreLabel.text = "Score: \(self.team?.claims.count ?? 0)"
        self.TeammatesLabel.text = "Teammates: \(self.makeNameString(players: self.teammates ?? []))"
        
        self.refreshOpponentState()
        self.OpponentScoreLabel.text = "Score: \(self.opponentTeam?.claims.count ?? 0)"
        self.OpponentsLabel.text = "Opponents: \(self.makeNameString(players: self.opponents ?? []))"
        
        self.refreshRoomStruct()
        self.LastMoveLabel.text = "Last Move: \(self.room?.move ?? "")"
        self.CurrentTurnLabel.text = "Turn: \(self.room?.turn ?? "")"
        
        
        self.refreshPlayerStruct()
        self.HandLabel.text = "Hand:\n\(self.makeStringOfHand())"
        self.refreshCardsAskFor()
        
        self.SelectCardPicker.reloadAllComponents();
        self.SelectOpponentPicker.reloadAllComponents();
    }
    
    func refreshPlayerStruct(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/players/\(self.player!.id)")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let player: Player = try! JSONDecoder().decode(Player.self, from: data)
            self.player = player
        }
        
        task.resume()
    }
    
    func refreshCardsAskFor(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/players/\(self.player!.id)/can_ask_for")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let cards: CardsCanAskFor = try! JSONDecoder().decode(CardsCanAskFor.self, from: data)
            self.cardsCanAskFor = cards.can_ask_for
        }
        
        task.resume()
    }
    
    // GETs the room struct from the server
    func refreshRoomStruct(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/rooms/\(self.player!.room_id)")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let room: Room = try! JSONDecoder().decode(Room.self, from: data)
            //print(room)
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
            //print(team)
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
            //print(players)
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
            //print(team)
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
            //print(players)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MakeClaim" {
            if segue.destination is ClaimViewController {
                let destination = segue.destination as! ClaimViewController
                destination.teamId = self.player?.team_id ?? nil
                destination.teammate1 = self.teammates?[0] ?? nil
                destination.teammate2 = self.teammates?[1] ?? nil
                destination.teammate3 = self.teammates?[2] ?? nil
            }
        }
    }

}
