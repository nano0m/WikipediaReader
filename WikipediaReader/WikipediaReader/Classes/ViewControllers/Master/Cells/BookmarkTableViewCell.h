//
//  BookmarkTableViewCell.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListItemTableViewCell.h"

#define BOOKMARK_TABLE_VIEW_CELL_NIB_DS @[@"BookmarkTableViewCell", @"BookmarkTableViewCell"]
@interface BookmarkTableViewCell : ListItemTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *iboDateLabel;

@end
