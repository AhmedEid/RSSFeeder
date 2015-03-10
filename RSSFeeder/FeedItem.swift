//
//  FeedItem.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var feedItemName: String
    @NSManaged var feedItemPublishedDate: NSDate
    @NSManaged var feedItemPublishedString: String
    @NSManaged var feedItemDescription: String
    @NSManaged var feedItemURLString: String
    @NSManaged var shouldShowInFeed:Bool
    @NSManaged var feed: Feed

}
