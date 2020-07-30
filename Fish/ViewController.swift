//
//  ViewController.swift
//  Fish
//
//  Created by Michael Zappa on 7/29/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var RoomName: UILabel!
    @IBOutlet weak var PlayerName: UILabel!
    
    @IBOutlet weak var RoomList: UIPickerView!
    var roomList: [String] = [String]()
    
    @IBOutlet weak var CreateRoomBtn: UIButton!
    @IBOutlet weak var DeleteRoomBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.RoomName.text = "Room: test"
        self.PlayerName.text = "Player: test"
        
        roomList = ["test1", "test2", "test3"]
        self.RoomList.delegate = self
        self.RoomList.dataSource = self
    }

    func numberOfComponents(in pickerView: UIPickerView)->Int{
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int)->Int{
        return roomList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)-> String?{
        return roomList[row]
    }

}



