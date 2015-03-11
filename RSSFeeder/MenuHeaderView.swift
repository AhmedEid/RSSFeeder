//
//  MenuHeaderView.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/10/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import UIKit

class MenuHeaderView:UIView {
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        topSeparatorView.backgroundColor = UIColor(rgba: "#dbdbdb")
        bottomSeparatorView.backgroundColor = UIColor(rgba: "#dbdbdb")
        backgroundColor = UIColor(rgba: "#f8f8f8")
        textLabel.textColor = UIColor(rgba: "#909090")
    }
}