//
//  BookmarkTableViewCell.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "BookmarkTableViewCell.h"

@implementation BookmarkTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.iboDateLabel.font = [UIFont fontWithName:selected?@"Helvetica-Bold":@"Helvetica" size:14];
}

@end
