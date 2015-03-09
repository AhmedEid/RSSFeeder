//
//  FeedItemTableViewCell.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/9/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import UIKit

class FeedItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedItemTitleLabel: UILabel!
    @IBOutlet weak var feedItemDescriptionLabel: UILabel!
    @IBOutlet weak var feedItemPublishedDateLabel: UILabel!
    
    var item:FeedItem? {
        didSet {
            self.feedItemTitleLabel.text = self.item?.feedItemName
            self.feedItemDescriptionLabel.text = self.item?.feedItemDescription;
            self.feedItemPublishedDateLabel.text = "0:00 PM"
        }
    }
}