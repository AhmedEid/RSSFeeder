	//
//  CoreDataManager.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject, NSXMLParserDelegate {
    
    let feeds = ["http://feeds.feedburner.com/TechCrunch/startups",
       "http://feeds.feedburner.com/TechCrunch/fundings-exits",
        "http://feeds.feedburner.com/TechCrunch/social",
        "http://feeds.feedburner.com/Mobilecrunch",
        "http://feeds.feedburner.com/crunchgear",
        "http://feeds.feedburner.com/TechCrunch/gaming",
        "http://feeds.feedburner.com/Techcrunch/europe",
        "http://feeds.feedburner.com/TechCrunchIT",
        "http://feeds.feedburner.com/TechCrunch/greentech"];
    
    var parser: NSXMLParser = NSXMLParser()
    var feedName: String = String()
    var feedItemName: String = String()
    var feedItemDescription: String = String()
    var feedItemPublishedDate: String = String()
    var feedItemURLString: String = String()
    var eName: String = String()
    
    let dateFormatter = NSDateFormatter()
    
    var currentFeed:Feed?
    
    var hasParsedChannelTitle:Bool = false
    
    //MARK: - Singleton
    
    class var shared:CoreDataManager{
        get {
            struct Static {
                static var instance : CoreDataManager? = nil
                static var token : dispatch_once_t = 0
            }
            dispatch_once(&Static.token) { Static.instance = CoreDataManager() }
            
            return Static.instance!
        }
    }
    
    //MARK: - Feed Loading 
    
    func loadFeedsFromServer() {
        
        for feedURLString in feeds {
            println(feedURLString)
            parser = NSXMLParser(contentsOfURL:NSURL(string: feedURLString))!
            parser.delegate = self
            parser.parse()
        }
    }
    
    func fetchFeeds() -> [Feed] {
        let request = NSFetchRequest(entityName: "Feed")
        if let results = managedObjectContext!.executeFetchRequest(request, error: nil) as? [Feed] {
            for feed in results {
                println("Fetched Feed \(feed.feedName)")
            }

            return results as [Feed]
        }
        return []
    }
    
    // MARK: - NSXMLParserDelegate methods
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        eName = elementName
        
        if elementName == "title" {
            feedName = String()
        } else if elementName == "item" {
            feedItemName = String()
            feedItemURLString = String()
            feedItemDescription = String()
            feedItemPublishedDate = String()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        let data = string!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (!data.isEmpty) {
            if eName == "title" && hasParsedChannelTitle == false {
                feedName += data
            } else if eName == "link" {
                feedItemURLString += data
            } else if eName == "title" && hasParsedChannelTitle == true {
                feedItemName += data
            } else if eName == "description" {
                feedItemDescription += data
            } else if eName == "pubDate" {
                feedItemPublishedDate += data
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "title" &&  hasParsedChannelTitle == false {
            hasParsedChannelTitle = true
            var request: NSFetchRequest = NSFetchRequest(entityName:"Feed")
            request.predicate = NSPredicate(format: "feedName = %@", feedName)
            
            var results : [Feed]? = managedObjectContext!.executeFetchRequest(request, error: nil) as? [Feed]
                
                if (results != nil && results?.count > 0) {
                    currentFeed = results![0] as Feed
                    println("Fetched feed : \(currentFeed!.feedName)")
            } else {
                    if let feed = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(Feed), inManagedObjectContext: self.managedObjectContext!) as? Feed {
                        feed.feedName = feedName;
                        currentFeed = feed
                        println("Created Feed named \(feed.feedName)")
                    }
                    self.saveContext()
            }
        } else if elementName == "item" {
            let item = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(FeedItem), inManagedObjectContext: self.managedObjectContext!) as! FeedItem
            item.feedItemName = feedItemName
            item.feedItemURLString = feedItemURLString
            item.feedItemDescription = feedItemDescription
            
            dateFormatter.dateFormat = "EEE, dd MM yyyy HH:mm:ss zzz"
            if let date = dateFormatter.dateFromString(feedItemPublishedDate) {
                item.feedItemPublishedDate = date
            }
            
            
            if let feed = currentFeed {
                var request: NSFetchRequest = NSFetchRequest(entityName:"Feed")
                request.predicate = NSPredicate(format: "feedName = %@", feed.feedName)
                let results = managedObjectContext!.executeFetchRequest(request, error: nil) as! [Feed]
                
                if (results.count > 0) {
                    if let fetchedFeed = results[0] as Feed? {
                        if let manyRelation = fetchedFeed.valueForKeyPath("items") as? NSMutableSet {
                            manyRelation.addObject(item)
                            println("Appended item \(item.feedItemName) to feed \(fetchedFeed.feedName)")
                            self.saveContext()
                        }
                    }
                }
            }
        }
        self.saveContext()
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        hasParsedChannelTitle = false
    }
    
    //MARK: - Core Data Stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "AE.RSSFeeder" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("RSSFeeder", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("RSSFeeder.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}