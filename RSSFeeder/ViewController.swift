//
//  ViewController.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //Data 
    var feeds:[Feed] = []
    
    var currentFeed:Feed? {
        didSet {
            if let itemsArray : [FeedItem] = self.currentFeed?.items.allObjects as? [FeedItem] {
                let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
                if let feedItemToPresent = sortedItemsArray.first {
                    self.currentFeedItem = feedItemToPresent
                    if let i = find(sortedItemsArray, feedItemToPresent) {
                        self.indexOfCurrentArticleInFeed = i
                    }
                }
            }
        }
    }
    
    var currentFeedItem:FeedItem? {
        didSet {
            titleLabel.text = self.currentFeedItem?.feedItemName
            webView.loadRequest(NSURLRequest(URL: NSURL(string: self.currentFeedItem!.feedItemURLString)!))
        }
    }

    //View Controllers
    let menuViewController: MenuViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
    
    //Views
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var titleLabel: UILabel!
    var blackOverlayView = UIView(frame: CGRectZero)
    
    //Constraints 
    var menuLeftConstraint:NSLayoutConstraint?
    
    //State
    var isShowingMenu = true
    var indexOfCurrentArticleInFeed = 0
    
    //Actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        toggleMenu()
    }
    
    @IBAction func previousArticleButtonTapped(sender: AnyObject) {
        if let itemsArray : [FeedItem] = currentFeed?.items.allObjects as? [FeedItem] {
            let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
            
            let previousIndex = self.indexOfCurrentArticleInFeed-1
            
            if (previousIndex >= 0) {
                let previousFeedItem = sortedItemsArray[previousIndex]
                self.currentFeedItem = previousFeedItem
                indexOfCurrentArticleInFeed = previousIndex
            }
        }
    }
    
    @IBAction func nextArticleButtonTapped(sender: AnyObject) {
        if let itemsArray : [FeedItem] = currentFeed?.items.allObjects as? [FeedItem] {
            let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })

            let nextIndex = self.indexOfCurrentArticleInFeed+1
            
            if (nextIndex < sortedItemsArray.count) {
                let nextFeedItem = sortedItemsArray[nextIndex]
                self.currentFeedItem = nextFeedItem
                indexOfCurrentArticleInFeed = nextIndex
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addMenuViewController()
        
//        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://Apple.com")!))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        feeds = CoreDataManager.shared.fetchFeeds()
        currentFeed = feeds.first
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - Menu
    
    func addMenuViewController() {
        addChildViewController(menuViewController)
        menuViewController.didMoveToParentViewController(self)
        menuViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(menuViewController.view)
        
        let topConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 300)

        menuLeftConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: -widthConstraint.constant)
        
        let bottomConstraint = NSLayoutConstraint(item: menuViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        
        view .addConstraints([topConstraint, menuLeftConstraint!, bottomConstraint, widthConstraint])
        
        toggleMenu()
    }
    
    func toggleMenu() {
        isShowingMenu = !isShowingMenu
        
        if (isShowingMenu){
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
            menuLeftConstraint?.constant = -menuViewController.view.bounds.size.width
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: { (completed) -> Void in
                self.menuViewController.view.hidden = true
            })
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.blackOverlayView.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.blackOverlayView.removeFromSuperview()
            })
            
        } else {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)

            blackOverlayView = UIView(frame: CGRectZero)
            blackOverlayView.alpha = 0;
            blackOverlayView.setTranslatesAutoresizingMaskIntoConstraints(false)
            blackOverlayView.backgroundColor = UIColor.blackColor()
            view.insertSubview(blackOverlayView, belowSubview: menuViewController.view)
            
            let topConstraint = NSLayoutConstraint(item: blackOverlayView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: blackOverlayView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: blackOverlayView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: blackOverlayView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
            view.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
            view.layoutIfNeeded()
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.blackOverlayView.alpha = 0.5
                }, completion: { (completed) -> Void in
                    let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureRecognized")
                    self.blackOverlayView.addGestureRecognizer(tapGesture)
            })
            
            menuViewController.view.hidden = false
            menuLeftConstraint?.constant = 0
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
            })
        }
    }
    
    func tapGestureRecognized() {
        toggleMenu()
    }
}

