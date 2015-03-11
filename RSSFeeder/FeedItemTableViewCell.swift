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
    
    @IBOutlet weak var feedItemDescriptionLabelHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        selectionStyle = .None
        self.feedItemPublishedDateLabel.textColor = UIColor(rgba: "#b1b1b1")
    }
    
    var item:FeedItem? {
        didSet {
            self.feedItemTitleLabel.text = self.item?.feedItemName
            self.feedItemDescriptionLabel.text = self.item?.feedItemDescription;
            self.feedItemPublishedDateLabel.text = self.item?.feedItemPublishedString
            
            self.feedItemDescriptionLabelHeightConstraint.constant = min(heightForView(self.item!.feedItemDescription, font: self.feedItemDescriptionLabel.font, width: self.feedItemDescriptionLabel.bounds.size.width), CGFloat(40))
            layoutIfNeeded()
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}