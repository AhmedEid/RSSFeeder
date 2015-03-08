//
//  ViewController.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoreDataManager.shared.loadFeeds()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

