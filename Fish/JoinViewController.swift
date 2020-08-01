//
//  ViewController.swift
//  Fish
//
//  Created by Michael Zappa on 7/29/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Outlets to UI Elements
    @IBOutlet weak var CreateRoomNameField: UITextField!
    @IBOutlet weak var CreateRoomBtn: UIButton!
    @IBOutlet weak var DeleteRoomBtn: UIButton!
    @IBOutlet weak var RoomList: UIPickerView!
    @IBOutlet weak var PlayerNameField: UITextField!
    @IBOutlet weak var JoinRoomBtn: UIButton!
    
    // State of the app
    let session = URLSession.shared
    var roomNameList: [String] = [String]()
    
    // Values to pass on to the game view once properly initialized
    var joinedRoomName: String? = nil
    var joiningPlayer: Player? = nil
    
    var refreshTimer: Timer?
    
    override func viewDidLoad() {
        // refresh from server
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            self.refreshRoomList()
            
            self.RoomList.reloadAllComponents();
        }
        
        // UIPickerView setup
        self.RoomList.delegate = self
        self.RoomList.dataSource = self
        
        self.CreateRoomBtn.addTarget(self, action: #selector(createRoom), for: .touchDown)
        self.DeleteRoomBtn.addTarget(self, action: #selector(deleteRoom), for: .touchDown)
        self.JoinRoomBtn.addTarget(self, action: #selector(joinRoom), for: .touchDown)
        super.viewDidLoad()
    }

    // Sends HTTP Post Request to server to create a room
    @objc func createRoom(){
        //print("Create Button tapped")
        let roomName = self.CreateRoomNameField.text
        //print(roomName!)
        
        let url = URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/rooms")
        guard let requestUrl = url else { fatalError() }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
        
        let json: [String: Any] = ["name": "\(roomName!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])

        let task = session.uploadTask(with: request, from: jsonData) { (data, response, error) in
               //print(data)
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    //print(dataString)
                    switch dataString {
                        case "{\"error\":\"duplicate room name, creation failed\"}":
                            print("duplicate room name, creation failed")
                        default:
                            print("Room created")
                    }
                }
        }
        task.resume()
        
        self.CreateRoomNameField.text = ""
    }
    
    // deletes room with HTTP DELETE REQUEST
    @objc func deleteRoom(){
        //print("Delete Button tapped")
        let selectedRoomIndex = self.RoomList.selectedRow(inComponent: 0)
        let roomName = self.roomNameList[selectedRoomIndex]
        //print(roomName)
        
        let url = URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/rooms/\(roomName)")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "DELETE"

        let task = session.dataTask(with: request) { (data, response, error) in
            //print(data)
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
        }
        task.resume()
        
        self.CreateRoomNameField.text = ""
    }
    
    // sends POST request to add player to room on server
    @objc func joinRoom(){
        print("Join Button tapped")
        let selectedRoomIndex = self.RoomList.selectedRow(inComponent: 0)
        let roomName = self.roomNameList[selectedRoomIndex]
        print(roomName)
        
        let playerName = self.PlayerNameField.text;
        print(playerName!)
        
        let url = URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/players")
        guard let requestUrl = url else { fatalError() }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
        
        let json: [String: Any] = ["room_name": "\(roomName)", "player_name": "\(playerName!)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])

        let task = session.uploadTask(with: request, from: jsonData) { (data, response, error) in
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        //print(dataString)
                        switch dataString{
                            case "{\"error\":\"duplicate player name, creation failed\"}":
                                print("duplicate player name, creation failed")
                            case "{\"error\":\"both teams full\"}":
                                print("both teams full")
                            default:
                                let player: Player = try! JSONDecoder().decode(Player.self, from: data)
                                //print(player)
                                self.joiningPlayer = player
                                self.joinedRoomName = roomName
                        }
                    }
        }
        task.resume()
        
        self.CreateRoomNameField.text = ""
    }
    
    // refreshes the displayed room list from the server with an HTTP GET request
    func refreshRoomList(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/rooms")
        guard let requestURL = url else { fatalError() }
        
        let task = session.dataTask(with: requestURL) {(data, response, error) in
            guard let data = data else { return }
            let rooms: [Room] = try! JSONDecoder().decode([Room].self, from: data)
            //print(String(data: data, encoding: .utf8)!)
            //print(rooms)
            self.roomNameList = []
            for room in rooms {
                //print(room)
                self.roomNameList.append(room.name)
            }
            //print(self.roomNameList)
        }
        
        task.resume()
    }
    
    func numberOfComponents(in pickerView: UIPickerView)->Int{
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int)->Int{
        return roomNameList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String?{
        return roomNameList[row]
    }

    // transmits the player name and room name to the GameViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JoinGame" {
            if segue.destination is GameViewController {
                let destination = segue.destination as! GameViewController
                destination.player = self.joiningPlayer!
                destination.roomName = self.joinedRoomName!
            }
        }
    }
}



