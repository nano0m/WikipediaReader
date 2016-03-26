//
//  ListItemTableViewCell.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "ListItemTableViewCell.h"

@implementation ListItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.iboTitleLabel.font = [UIFont fontWithName:selected?@"Helvetica-Bold":@"Helvetica" size:18];
}

@end
