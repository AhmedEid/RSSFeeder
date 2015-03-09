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

class MenuViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    internal var context: NSManagedObjectContext = CoreDataManager.shared.managedObjectContext!
    
    @IBOutlet weak var tableView: UITableView!
    var feeds = [Feed]()
    
    override internal func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.yellowColor()
        
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
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let feed = feeds[indexPath.section]
        var itemsArray : [FeedItem] = feed.items.allObjects as! [FeedItem]
        let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
        let item = sortedItemsArray[indexPath.row]
        println("\(item.feedItemPublishedDate)")
        cell.textLabel?.text = item.feedItemName
        
        return cell
    }
    
    internal func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let feed = feeds[section]
        return feed.feedName
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feed = feeds[indexPath.section]
        var itemsArray : [FeedItem] = feed.items.allObjects as! [FeedItem]
        let sortedItemsArray : [FeedItem] = itemsArray.sorted({ $0.feedItemPublishedDate.compare($1.feedItemPublishedDate) == NSComparisonResult.OrderedDescending })
        let item = sortedItemsArray[indexPath.row]
        //Pass item to viewController
    }
}