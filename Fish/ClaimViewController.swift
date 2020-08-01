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
    let session = URLSession.shared
    
    @IBOutlet weak var SelectHalfsuitBtn: UIButton!
    @IBOutlet weak var SelectCards1Btn: UIButton!
    @IBOutlet weak var SelectCards2Btn: UIButton!
    @IBOutlet weak var SelectCards3Btn: UIButton!
    @IBOutlet weak var MakeClaimBtn: UIButton!
    
    var selectedHalfsuitName: String = ""
    var selectedHalfsuitID: Int = -1
    var selectedHalfsuitCards: [String] = []
    
    var teamId: Int? = nil;
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
        
        self.SelectHalfsuitBtn.addTarget(self, action: #selector(showSelectHalfsuitMenu), for: .touchDown)
        self.MakeClaimBtn.addTarget(self, action: #selector(makeClaim), for: .touchDown)
    }
    
    // sends to the server at attempt to make specified claim
    @objc func makeClaim(){
        let teammate1Id = self.teammate1!.id
        let teammate2Id = self.teammate2!.id
        let teammate3Id = self.teammate3!.id
        
        let url = URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/teams/\(self.teamId!)")
        guard let requestUrl = url else { fatalError() }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Powered by Swift!", forHTTPHeaderField: "X-Powered-By")
        
        let json: [String: Any] = ["player_card_map":[
            "\(teammate1Id)": self.teammate1Cards,
            "\(teammate2Id)": self.teammate2Cards,
            "\(teammate3Id)": self.teammate3Cards]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        print(url)
        print(json)
        let task = session.uploadTask(with: request, from: jsonData) { (data, response, error) in
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                    switch dataString{
                    case "{\"error\":\"invalid claim\"}":
                        print("invalid claim")
                    case "{\"error\":\"the specified cards are not all in play\"}":
                        print("claim not in play")
                    default:
                        return
                    }
                }
        }
        task.resume()
    }
    
    @objc func showSelectHalfsuitMenu(){
        let data: [HalfSuit] = [
            HalfSuit(name: "Low Hearts", id: 0),
            HalfSuit(name: "High Hearts", id: 1),
            HalfSuit(name: "Low Diamonds", id: 2),
            HalfSuit(name: "High Diamonds", id: 3),
            HalfSuit(name: "Low Spades", id: 4),
            HalfSuit(name: "High Spades", id: 5),
            HalfSuit(name: "Low Clubs", id: 6),
            HalfSuit(name: "High Clubs", id: 7),
            HalfSuit(name: "Eights and Jokers", id: 8)]
        let menu = RSSelectionMenu(dataSource: data) { (cell, halfsuit, indexPath) in
            cell.textLabel?.text = halfsuit.name
        }
        menu.onDismiss = { selectedItems in
            self.selectedHalfsuitName = selectedItems[0].name
            self.selectedHalfsuitID = selectedItems[0].id
            let url=URL(string: "https://glistening-stale-arcticfox.gigalixirapp.com/cards/\(self.selectedHalfsuitID)")
            guard let requestURL = url else { fatalError() }
            
            let task = self.session.dataTask(with: requestURL) {(data, response, error) in
                guard let data = data else { return }
                let cardsInHalfSuit: CardsInHalfSuit = try! JSONDecoder().decode(CardsInHalfSuit.self, from: data)
                //print(players)
                self.selectedHalfsuitCards = cardsInHalfSuit.cards
                print(self.selectedHalfsuitCards)
            }
            
            task.resume()
            print(self.selectedHalfsuitName, ", ", self.selectedHalfsuitID)
        }
        menu.show(from: self)
    }
    
    @objc func setTeamamte1Claim(){
        self.showSelectCardsMenu(teammateNum: 1)
    }
    
    @objc func setTeamamte2Claim(){
        self.showSelectCardsMenu(teammateNum: 2)
    }
    
    @objc func setTeamamte3Claim(){
        self.showSelectCardsMenu(teammateNum: 3)
    }
    
    func showSelectCardsMenu(teammateNum: Int){
        //let data: [String] = ["2-S", "3-S", "4-S", "5-S", "6-S", "7-S"]
        //let data: [String] = self.cardHalfsuitMap.
        let menu = RSSelectionMenu(selectionStyle: .multiple, dataSource: self.selectedHalfsuitCards) { (cell, name, indexPath) in
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
