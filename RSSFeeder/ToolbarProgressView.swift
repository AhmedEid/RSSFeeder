//
//  ToolbarProgressView.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/9/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import UIKit

class ToolbarProgressView :UIView {
    @IBOutlet weak var progressViewTextLabel: UILabel!
    @IBOutlet weak var progressViewPageControl: UIPageControl!
    
    override func awakeFromNib() {
        progressViewPageControl.currentPageIndicatorTintColor = UIColor.grayColor()
        progressViewPageControl.pageIndicatorTintColor = UIColor.redColor()
    }
}