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
        
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let itemsFetchRequest = NSFetchRequest(entityName: "FeedItem")
        itemsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "feed.feedName", ascending: true), NSSortDescriptor(key: "feedItemName", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: itemsFetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    override internal func viewDidLoad() {
        
        super.viewDidLoad()

        CoreDataManager.shared.loadFeeds()

        var error: NSError? = nil
        if (fetchedResultsController.performFetch(&error) == false) {
            print("An error occurred: \(error?.localizedDescription)")
        }
        
    }
    
    // MARK: TableView Data Source
    internal func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as FeedItem
        cell.textLabel?.text = item.feedItemName
        
        return cell
    }
    
    internal func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as NSFetchedResultsSectionInfo
            return currentSection.name
        }
        
        return nil
    }
}