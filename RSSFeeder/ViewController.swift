//
//  ViewController.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let menuViewController: MenuViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewController") as MenuViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoreDataManager.shared.loadFeeds()
        
        addChildViewController(menuViewController)
        menuViewController.didMoveToParentViewController(self)
        menuViewController.view.frame = view.bounds
        view.addSubview(menuViewController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

