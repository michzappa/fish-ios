//
//  GameViewController.swift
//  Fish
//
//  Created by Michael Zappa on 7/30/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    
    @IBOutlet weak var RoomNameLabel: UILabel!
    @IBOutlet weak var PlayerNameLabel: UILabel!
    @IBOutlet weak var HandLabel: UILabel!
    
    var player: Player? = nil;
    var roomName: String? = nil;
    
    var refreshTimer: Timer?
    
    override func viewDidLoad() {
        // refresh from server
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            
        }
        
        self.RoomNameLabel.text = "Room: \(self.roomName!)"
        self.PlayerNameLabel.text = "Player: \(self.player!.name)"
        self.HandLabel.text = "Hand:\n\(self.makeStringOfHand())"
        super.viewDidLoad()
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
