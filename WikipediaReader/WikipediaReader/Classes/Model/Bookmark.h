//
//  Bookmark.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bookmark : NSObject

@property(assign, nonatomic) NSInteger bookmarkId;
@property(copy, nonatomic) NSString *bookmarkUrl;
@property(copy, nonatomic) NSString *bookmarkTitle;
@property(strong, nonatomic) NSDate *bookmarkDate;

- (instancetype)initWithBookmark:(Bookmark*)bookmark;
- (BOOL)isFavorite;

@end
