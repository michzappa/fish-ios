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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.SelectCards1Btn.addTarget(self, action: #selector(showSelectMenu), for: .touchDown)
    }
    
    @objc func showSelectMenu(){
        let data: [String] = ["2-S", "3-S", "4-S", "5-S", "6-S", "7-S"]
        var selectedNames: [String] = []// create menu with data source -> here [String]
        let menu = RSSelectionMenu(selectionStyle: .multiple, dataSource: data) { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }// provide selected items
        menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
            selectedNames = selectedItems
            print(selectedItems)
        }
        // show - Present
        menu.show(from: self)
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
