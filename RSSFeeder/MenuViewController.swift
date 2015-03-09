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
    func didSelectFeedItem(feed:Feed, item:FeedItem)
    func menuCloseButtonTapped()
}

class MenuViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //Data
    internal var context: NSManagedObjectContext = CoreDataManager.shared.managedObjectContext!
    var feeds = [Feed]()

    //Views
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: MenuDelegate?
    
    @IBAction func menuCloseButtonTapped(sender: AnyObject) {
        delegate?.menuCloseButtonTapped()
    }
    
    override internal func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.yellowColor()
        tableView.registerNib(UINib(nibName: "FeedItemTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedItemTableViewCell")
        
        CoreDataManager.shared.loadFeedsFromServer()
        feeds = CoreDataManager.shared.fetchFeeds()
        tableView.reloadData()

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
        return 45
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, view.bounds.size.width, 45))
        headerView.backgroundColor = UIColor.lightGrayColor()
        let label = UILabel(frame: headerView.frame)
        label.textColor = UIColor.darkGrayColor()
        let feed = feeds[section]
        label.text = feed.feedName;
        
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedItemTableViewCell", forIndexPath: indexPath) as! FeedItemTableViewCell
        let feed = feeds[indexPath.section]
        var itemsArray : [FeedItem] = feed.items.allObjects as! [FeedItem]
        let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
        let item = sortedItemsArray[indexPath.row]
        cell.item = item;
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