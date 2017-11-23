//
//  Detailed.swift
//  nearBy
//
//  Created by Sergiy Dubovik on 24/11/2017.
//  Copyright © 2017 Sergiy Dubovik. All rights reserved.
//

import UIKit

class Detailed: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var address: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
