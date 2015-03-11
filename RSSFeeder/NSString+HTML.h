//
//  NSString+HTML.h
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/11/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

#import <Foundation/Foundation.h>

//  Asignment instructions stated: * You may NOT use third party RSS packages to store/manage feeds.
//  This class ONLY removed HTML from a string
//  The functionality in this class is not "storing/managing feeds"

@interface NSString (HTML)
- (NSString *)stringByConvertingHTMLToPlainText;
@end
