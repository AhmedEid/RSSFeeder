    //
    //  CoreDataManager.swift
    //  RSSFeeder
    //
    //  Created by Ahmed Eid on 3/7/15.
    //  Copyright (c) 2015 AhmedEid. All rights reserved.
    //
    
    import Foundation
    import CoreData
    
    protocol CoreDataManagerDelegate {
        func coreDataManagerDidFinishDownloadingFeeds(feeds:[Feed])
    }
    
    class CoreDataManager: NSObject, NSXMLParserDelegate {
        
        var delegate: CoreDataManagerDelegate?
        
        let feeds = ["http://feeds.feedburner.com/TechCrunch/startups",
            "http://feeds.feedburner.com/TechCrunch/fundings-exits",
            "http://feeds.feedburner.com/TechCrunch/social",
            "http://feeds.feedburner.com/Mobilecrunch",
            "http://feeds.feedburner.com/crunchgear",
            "http://feeds.feedburner.com/TechCrunch/gaming",
            "http://feeds.feedburner.com/Techcrunch/europe",
            "http://feeds.feedburner.com/TechCrunchIT",
            "http://feeds.feedburner.com/TechCrunch/greentech"];
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)

        var parser: NSXMLParser = NSXMLParser()
        var feedName: String = String()
        var feedItemName: String = String()
        var feedItemDescription: String = String()
        var feedItemPublishedDate: String = String()
        var feedItemURLString: String = String()
        var eName: String = String()
        
        let dateFormatter = NSDateFormatter()
        
        var initializedDate:NSDate?
        var lastServerUpdatedDate: NSDate?
        
        var currentFeed:Feed?
        
        var hasParsedChannelTitle:Bool = false
        var parsedFeeds = 0
        
        var loadingTimer = NSTimer()

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
        
        override init() {
            super.init()
            loadingTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
            loadingTimer.fire()
            initializedDate = NSDate()
        }
        
        func timerFire(timer:NSTimer) {
            //Check if not downloading/parsing data 
            //Check if time alapsed > 300 seconds from last update
            //Load Data 
            
            if let lastServerUpdatedDate = lastServerUpdatedDate {
                let lastServerElapsedTime:NSTimeInterval  = NSDate().timeIntervalSinceDate(lastServerUpdatedDate)
                println(lastServerElapsedTime)
                if Int(lastServerElapsedTime) > 60 {
                    if let lastInitializedDate = initializedDate {
                        let elapsedTime:NSTimeInterval  = NSDate().timeIntervalSinceDate(lastInitializedDate)
                        println(elapsedTime)
                        //Update every 300 seconds in the foreground
                        if Int(elapsedTime) > 300 {
                            initializedDate = NSDate()
                            loadData()
                        }
                    }
                }
            }
        }
        
        //MARK: - Feed Loading
        
        func loadFeedsFromServer(#force:Bool) {
            if (force == true){
                loadData()
            } else {
                //Never more than once per minute unless initiated by the user
                if let lastUpdatedDate = lastServerUpdatedDate {
                    let elapsedTime:NSTimeInterval  = NSDate().timeIntervalSinceDate(lastUpdatedDate)
                    println(elapsedTime)
                    if Int(elapsedTime) > 60 {
                        loadData()
                    }
                }
            }
        }
        
        func loadData() {
            deleteFeedItemsWithCompletionClosure({
                self.parsedFeeds = 0
                dispatch_async(self.backgroundQueue, {
                    for feedURLString in self.feeds {
                        println(feedURLString)
                        self.parser = NSXMLParser(contentsOfURL:NSURL(string: feedURLString))!
                        self.parser.delegate = self
                        self.parser.parse()
                    }
                })
            })
        }
        
        func fetchFeeds() -> [Feed] {
            let request = NSFetchRequest(entityName: "Feed")
            if let results = backgroundManagedObjectContext!.executeFetchRequest(request, error: nil) as? [Feed] {
                for feed in results {
                    let set = feed.items.filteredSetUsingPredicate(NSPredicate(format: "shouldShowInFeed = %@", true))
                    feed.items = set
                    println("Fetched Feed \(feed.feedName) with items \(feed.items.count)")
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
                
                var results : [Feed]? = backgroundManagedObjectContext!.executeFetchRequest(request, error: nil) as? [Feed]
                
                if (results != nil && results?.count > 0) {
                    currentFeed = results![0] as Feed
                    println("Fetched feed : \(currentFeed!.feedName)")
                } else {
                    if let feed = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(Feed), inManagedObjectContext: self.backgroundManagedObjectContext!) as? Feed {
                        feed.feedName = feedName;
                        currentFeed = feed
                        saveBackgroundContext()
                        println("Created Feed named \(feed.feedName)")
                    }
                }
            } else if elementName == "item" {
                let item = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(FeedItem), inManagedObjectContext: self.backgroundManagedObjectContext!) as! FeedItem
                item.shouldShowInFeed = true
                item.feedItemName = feedItemName
                item.feedItemURLString = feedItemURLString
                //            item.feedItemDescription = String(htmlEncodedString: feedItemDescription)
                item.feedItemDescription = feedItemDescription
                
                dateFormatter.dateFormat = "EEE, dd MM yyyy HH:mm:ss zzz"
                if let date = dateFormatter.dateFromString(feedItemPublishedDate) {
                    item.feedItemPublishedDate = date
                    
                    dateFormatter.dateFormat = "hh:mm a";
                    let dateString = dateFormatter.stringFromDate(date)
                    item.feedItemPublishedString = dateString
                    
                    let calendar = NSCalendar.currentCalendar()
                    let comp = calendar.components((NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit), fromDate: date)
                }
                
                
                if let feed = currentFeed {
                    item.feed = feed
//                    var request: NSFetchRequest = NSFetchRequest(entityName:"Feed")
//                    request.predicate = NSPredicate(format: "feedName = %@", feed.feedName)
//                    let results = backgroundManagedObjectContext!.executeFetchRequest(request, error: nil) as! [Feed]
//                    
//                    if (results.count > 0) {
//                        if let fetchedFeed = results[0] as Feed? {
//                            println("Appended item \(item.feedItemName) to feed \(fetchedFeed.feedName)")
//                        }
//                    }
                }
            }
        }
        
        func parserDidEndDocument(parser: NSXMLParser) {
            hasParsedChannelTitle = false
            parsedFeeds += 1
            
            if parsedFeeds == feeds.count {
                dispatch_async(backgroundQueue, {
                    
                    if (self.oldFeedItems!.count > 0) {
                        for item in self.oldFeedItems! {
                            item.shouldShowInFeed = false
                        }
                    }

                    self.saveBackgroundContext()
                    self.parsedFeeds = 0
                    self.lastServerUpdatedDate = NSDate()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.coreDataManagerDidFinishDownloadingFeeds(self.fetchFeeds())
                    })
                })
            }
        }
        
        var oldFeedItems:[FeedItem]?
        func deleteFeedItemsWithCompletionClosure(completionClosure: () -> ()) {
            var request: NSFetchRequest = NSFetchRequest(entityName:"FeedItem")
            let results = backgroundManagedObjectContext!.executeFetchRequest(request, error: nil) as! [FeedItem]
            oldFeedItems = results
            completionClosure()
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
            var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
            }()
        
        lazy var backgroundManagedObjectContext: NSManagedObjectContext? = {
            var backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            backgroundContext.parentContext = self.managedObjectContext
            return backgroundContext
            }()

        // MARK: - Core Data Saving support
        
        func saveMainContext () {
            if let moc = self.managedObjectContext {
                var error: NSError? = nil
                if moc.hasChanges && !moc.save(&error) {
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
        
        func saveBackgroundContext() {
            if let moc = self.backgroundManagedObjectContext {
                var error: NSError? = nil
                moc.save(&error)
                saveMainContext()
                println("Saved background MOC")
            }
        }
    }