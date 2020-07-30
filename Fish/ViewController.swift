//
//  ViewController.swift
//  Fish
//
//  Created by Michael Zappa on 7/29/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

struct Room: Decodable {
    let id: Int
    let move: String
    let name: String
    let turn: String
}

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var CreateRoomNameField: UITextField!
    
    @IBOutlet weak var CreateRoomBtn: UIButton!
    @IBOutlet weak var DeleteRoomBtn: UIButton!
    
    @IBOutlet weak var RoomList: UIPickerView!
    var roomNameList: [String] = [String]()
    
    var refreshTimer: Timer?
    
    override func viewDidLoad() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            self.refreshRoomList()
            
            [self.RoomList .reloadAllComponents()];
        }
        
        // UIPickerView setup
        self.RoomList.delegate = self
        self.RoomList.dataSource = self
        
        CreateRoomBtn.addTarget(self, action: #selector(createRoom), for: .touchDown)
        DeleteRoomBtn.addTarget(self, action: #selector(deleteRoom), for: .touchDown)
        super.viewDidLoad()
    }

    @objc func createRoom(){
        print("Create Button tapped")
        let roomName = self.CreateRoomNameField.text
        print(roomName!)
        self.CreateRoomNameField.text = ""
    }
    
    @objc func deleteRoom(){
        print("Delete Button tapped")
    }
    
    func refreshRoomList(){
        let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/rooms")
        guard let requestURL = url else { fatalError() }
        
        let task = URLSession.shared.dataTask(with: requestURL) {(data, response, error) in
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

}



