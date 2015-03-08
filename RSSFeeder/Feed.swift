//
//  Feed.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import Foundation
import CoreData

@objc(Feed)

class Feed: NSManagedObject {

    @NSManaged var feedName: String
    @NSManaged var items: NSSet

}
