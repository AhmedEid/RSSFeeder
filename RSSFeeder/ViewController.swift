//
//  ViewController.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, MenuDelegate, CoreDataManagerDelegate {
    
    //Data 
    var feeds:[Feed] = []
    var currentFeed:Feed?
    var currentFeedItem:FeedItem? {
        didSet {
            //Setting currentFeedItem will update title and load webView with feedItemURLString
            titleLabel.text = self.currentFeedItem?.feedItemName
            webView.loadRequest(NSURLRequest(URL: NSURL(string: self.currentFeedItem!.feedItemURLString)!))
        }
    }

    //View Controllers
    let menuViewController: MenuViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
    
    //Views
    @IBOutlet weak var nextArticleButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var blackOverlayView = UIView(frame: CGRectZero)
    var toolbarProgressView:ToolbarProgressView?
    
    //Constraints (Used to animate menu in/out)
    var menuLeftConstraint:NSLayoutConstraint?
    
    //State
    var isShowingMenu = true
    var indexOfCurrentArticleInFeed = 0
    var indexOfCurrentFeed = 0
    
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
                self.currentFeedItem = previousFeedItem //Setting item will automatically load webView + update title
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
                self.currentFeedItem = nextFeedItem //Setting item will automatically load webView + update title
                indexOfCurrentArticleInFeed = nextIndex
            }
        }
    }
    
    func previousFeedButtonTapped() {
        let previousIndex = self.indexOfCurrentFeed-1
        if (previousIndex >= 0) {
            let previousFeed = feeds[previousIndex]
            self.currentFeed = previousFeed
            indexOfCurrentFeed = previousIndex
            setupToolbar()

            //Set current article as first in previousFeed
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
    
    func nextFeedButtonTapped() {
        let nextIndex = self.indexOfCurrentFeed+1
        if (nextIndex < feeds.count) {
            let nextFeed = feeds[nextIndex]
            self.currentFeed = nextFeed
            indexOfCurrentFeed = nextIndex
            setupToolbar()

            //Set current article as first in nextFeed
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.delegate = self
        
        topBarView.backgroundColor = UIColor(rgba: "#3A59A3")
        
        let previousButtonImage = UIImage(named: "icon-arrow-big")
        let mirroredRightImage = UIImage(CGImage: previousButtonImage!.CGImage, scale:previousButtonImage!.scale , orientation: .UpMirrored)
        nextArticleButton.setImage(mirroredRightImage, forState: .Normal)
        nextArticleButton.setImage(mirroredRightImage, forState: .Highlighted)

        addMenuViewController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Load from Core Data Cache
        populateWithFeeds(CoreDataManager.shared.fetchFeeds())
    }
    
    //Mark: Data 
    
    func populateWithFeeds(feeds:[Feed]) {
        self.feeds = feeds
        currentFeed = self.feeds.first
        setupToolbar()

        //Set current article as first in feed
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
    
    func coreDataManagerDidFinishDownloadingFeeds(feeds: [Feed]) {
            populateWithFeeds(feeds)
    }
    
    func coreDataManagerDidFailDownloadingFeeds() {
    }
    
    //MARK - Menu & Menu Delegate
    
    func addMenuViewController() {
        addChildViewController(menuViewController)
        menuViewController.delegate = self
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
            //Hide Menu
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
            //Present Menu
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
                    let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureRecognized") //Will dismiss menu
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
    
    //MARK: Menu Delegate
    
    func didSelectFeedItem(feed: Feed, item:FeedItem) {
        toggleMenu()
        self.currentFeed = feed
        self.currentFeedItem = item
        
        //Set indexOfCurrentArticleInFeed
        if let itemsArray : [FeedItem] = self.currentFeed?.items.allObjects as? [FeedItem] {
            let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
                if let i = find(sortedItemsArray, currentFeedItem!) {
                    self.indexOfCurrentArticleInFeed = i
            }
        }
        
        //Set indexOfFeed
        if let i = find(feeds, currentFeed!) {
            self.indexOfCurrentFeed = i
        }

        setupToolbar()
    }
    
    func menuCloseButtonTapped() {
        toggleMenu()
    }
    
    //MARK: Toolbar
    
    func setupToolbar() {

        //Left Arrow View
        let leftImageView = UIImageView(image: UIImage(named: "icon-arrow-small"))
        leftImageView.frame = CGRectMake(0, 0, 7, 12)
        let leftImageButton = UIBarButtonItem(customView: leftImageView)
        
        //Left Feed Button
        let previousIndex = self.indexOfCurrentFeed-1
        var previousFeedTitle = ""
        if (previousIndex >= 0) {
            let previousFeed = feeds[previousIndex]
            previousFeedTitle = previousFeed.feedName
        }
        let leftFeedItem = UIBarButtonItem(title: previousFeedTitle, style: UIBarButtonItemStyle.Plain, target: self, action: "previousFeedButtonTapped")
        leftFeedItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        //Progress View
        toolbarProgressView = NSBundle.mainBundle().loadNibNamed("ToolbarProgressView", owner: self, options: nil)[0] as? ToolbarProgressView
        toolbarProgressView?.frame = CGRectMake(0, 0, 250, 20)
        toolbarProgressView?.progressViewTextLabel.text = currentFeed?.feedName
        toolbarProgressView?.progressViewPageControl.numberOfPages = feeds.count
        toolbarProgressView?.progressViewPageControl.currentPage = indexOfCurrentFeed
        
        let progressViewBarButtonItem = UIBarButtonItem(customView: toolbarProgressView!)
        
        //Next Feed Button
        let nextIndex = self.indexOfCurrentFeed+1
        var nextFeedTitle = ""
        if (nextIndex < feeds.count) {
            let nextFeed = feeds[nextIndex]
            nextFeedTitle = nextFeed.feedName
        }
        
        let rightFeedItem = UIBarButtonItem(title:nextFeedTitle, style: UIBarButtonItemStyle.Plain, target: self, action: "nextFeedButtonTapped")
        rightFeedItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)

        //Right  Arrow View
        let rightImage = UIImage(named: "icon-arrow-small")
        let mirroredRightImage = UIImage(CGImage: rightImage!.CGImage, scale:rightImage!.scale , orientation: .UpMirrored)
        let rightImageView = UIImageView(image: mirroredRightImage)
        rightImageView.frame = CGRectMake(0, 0, 7, 12)
        let rightImageButton = UIBarButtonItem(customView: rightImageView)
        
        if (!previousFeedTitle.isEmpty && !nextFeedTitle.isEmpty){
            toolbar.setItems([leftImageButton, leftFeedItem, flexibleItem, progressViewBarButtonItem, flexibleItem, rightFeedItem, rightImageButton], animated: false)

        } else if (nextFeedTitle.isEmpty){
            toolbar.setItems([leftImageButton, leftFeedItem, flexibleItem, progressViewBarButtonItem, flexibleItem, rightFeedItem], animated: false)
        } else {
            toolbar.setItems([leftFeedItem, flexibleItem, progressViewBarButtonItem, flexibleItem, rightFeedItem, rightImageButton], animated: false)
        }
    }
    
    //MARK: Gestures
    
    func tapGestureRecognized() {
        toggleMenu()
    }
    
    //MARK: WebView
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
    }
}

