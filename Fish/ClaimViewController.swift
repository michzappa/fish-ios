//
//  ClaimViewController.swift
//  Fish
//
//  Created by Michael Zappa on 7/31/20.
//  Copyright © 2020 Michael Zappa. All rights reserved.
//

import UIKit
import RSSelectionMenu
class ClaimViewController: UIViewController {

    @IBOutlet weak var SelectCards1Btn: UIButton!
    @IBOutlet weak var SelectCards2Btn: UIButton!
    @IBOutlet weak var SelectCards3Btn: UIButton!
    
    var teammate1: Player? = nil;
    var teammate1Cards: [String] = []
    var teammate2: Player? = nil;
    var teammate2Cards: [String] = []
    var teammate3: Player? = nil;
    var teammate3Cards: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.SelectCards1Btn.addTarget(self, action: #selector(setTeamamte1Claim), for: .touchDown)
        self.SelectCards1Btn.setTitle(self.teammate1?.name, for: .normal)
        
        self.SelectCards2Btn.addTarget(self, action: #selector(setTeamamte2Claim), for: .touchDown)
        self.SelectCards2Btn.setTitle(self.teammate2?.name, for: .normal)
        
        self.SelectCards3Btn.addTarget(self, action: #selector(setTeamamte3Claim), for: .touchDown)
        self.SelectCards3Btn.setTitle(self.teammate3?.name, for: .normal)
    }
    
    @objc func setTeamamte1Claim(){
        self.showSelectMenu(teammateNum: 1)
    }
    
    @objc func setTeamamte2Claim(){
        self.showSelectMenu(teammateNum: 2)
    }
    
    @objc func setTeamamte3Claim(){
        self.showSelectMenu(teammateNum: 3)
    }
    
    func showSelectMenu(teammateNum: Int){
        let data: [String] = ["2-S", "3-S", "4-S", "5-S", "6-S", "7-S"]
        let menu = RSSelectionMenu(selectionStyle: .multiple, dataSource: data) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        menu.onDismiss = { selectedItems in
            switch teammateNum{
            case 1:
                self.teammate1Cards = selectedItems
                print("1: ", self.teammate1Cards)
            case 2:
                self.teammate2Cards = selectedItems
                print("2: ",  self.teammate2Cards)
            case 3:
                self.teammate3Cards = selectedItems
                print("3: ", self.teammate3Cards)
            default: print("Not a valid teammate number")
            }
            
        }
        menu.show(from: self)
    }
}
