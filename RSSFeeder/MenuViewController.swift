//
//  MenuViewController.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol MenuDelegate {
    //Menu Delegate used to notify ViewController of selection of feed item
    func didSelectFeedItem(feed:Feed, item:FeedItem)
    func menuCloseButtonTapped()
}

class MenuViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, CoreDataManagerDelegate {
    
    internal var context: NSManagedObjectContext = CoreDataManager.shared.managedObjectContext!
    var feeds = [Feed]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var topBarView: UIView!
    let refreshControl = UIRefreshControl()
    
    var delegate: MenuDelegate?
    var isDownloadingFeeds = false
    
    @IBAction func menuCloseButtonTapped(sender: AnyObject) {
        delegate?.menuCloseButtonTapped()
    }
    
    override internal func viewDidLoad() {
        
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.backgroundColor = UIColor.whiteColor()
        topBarView.backgroundColor = UIColor(rgba: "#3A59A3")
        tableView.registerNib(UINib(nibName: "FeedItemTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedItemTableViewCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        //Will recieve callback when load succeded/failed
        CoreDataManager.shared.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Load from Core data cache
        let fetchedFeeds = CoreDataManager.shared.fetchFeeds()
        populateDataWithFeeds(fetchedFeeds)
    }
    
    //MARK: Data
    
    func loadData () {
        if isDownloadingFeeds == true {
            return;
        }
        
        activityIndicatorView.startAnimating()
        isDownloadingFeeds = true
        
        //Ignore rules regarding loading times and force load of feeds initiated by user
        CoreDataManager.shared.loadFeedsFromServer(force: true)
    }
    
    func coreDataManagerDidFinishDownloadingFeeds(feeds: [Feed]) {
            populateDataWithFeeds(feeds)
    }
    
    func coreDataManagerDidFailDownloadingFeeds() {
        refreshControl.endRefreshing()
    }
    
    func populateDataWithFeeds(feeds:[Feed]) {
        isDownloadingFeeds = false
        activityIndicatorView.stopAnimating()
        self.feeds = feeds
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func refresh(sender:AnyObject) {
        loadData()
    }
    
    // MARK: TableView Data Source
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return feeds.count
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let feed = feeds[section]
        return feed.items.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = NSBundle.mainBundle().loadNibNamed("MenuHeaderView", owner: self, options: nil)[0] as? MenuHeaderView
             let feed = feeds[section]
        headerView?.textLabel.text = feed.feedName;
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedItemTableViewCell", forIndexPath: indexPath) as! FeedItemTableViewCell
        let feed = feeds[indexPath.section]
        if let itemsArray : [FeedItem] = feed.items.allObjects as? [FeedItem] {
            //Sort feed items by published date
            let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
            let item = sortedItemsArray[indexPath.row]
            cell.item = item;
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feed = feeds[indexPath.section]
        var itemsArray : [FeedItem] = feed.items.allObjects as! [FeedItem]
        let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
        let item = sortedItemsArray[indexPath.row]
        delegate?.didSelectFeedItem(feed, item: item)
    }
}