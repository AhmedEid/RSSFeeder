//
//  FeedItem.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/10/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var feedItemDescription: String
    @NSManaged var feedItemName: String
    @NSManaged var feedItemPublishedDate: NSDate
    @NSManaged var feedItemURLString: String
    @NSManaged var feedItemPublishedString: String
    @NSManaged var shouldShowInFeed: NSNumber
    @NSManaged var feed: Feed

}
