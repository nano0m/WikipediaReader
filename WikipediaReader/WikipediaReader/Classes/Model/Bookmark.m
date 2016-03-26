//
//  Bookmark.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "Bookmark.h"

@implementation Bookmark

- (instancetype)initWithBookmark:(Bookmark*)bookmark{
    self = [super init];
    
    if (self) {
        _bookmarkTitle = [bookmark bookmarkTitle];
        _bookmarkUrl = [bookmark bookmarkUrl];
    }
    
    return self;
}

- (BOOL)isFavorite{
    return nil!=self.bookmarkDate;
}

@end
