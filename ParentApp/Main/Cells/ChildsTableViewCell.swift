//
//  ConditionsTableViewCell.swift
//  HoldenKnight
//
//  Created by Farghaly on 3/8/20.
//  Copyright © 2020 Test.iosapp. All rights reserved.
//

import UIKit

class ChildsTableViewCell: UITableViewCell {

    @IBOutlet weak var childName: UILabel!
    @IBOutlet weak var childEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setupChildData(user: User){
        childName.text = user.name
        childEmail.text = user.email
    }

}
