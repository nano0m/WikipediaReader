//
//  ListItemTableViewCell.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

#define LIST_ITEM_TABLE_VIEW_CELL_NIB_DS @[@"ListItemTableViewCell", @"ListItemTableViewCellID"]
@interface ListItemTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *iboTitleLabel;

@end
