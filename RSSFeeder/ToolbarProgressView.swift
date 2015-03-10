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
        progressViewPageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        progressViewPageControl.pageIndicatorTintColor = UIColor(rgba:"#c7c7c7")
        progressViewPageControl.backgroundColor = UIColor.clearColor()
    }
}