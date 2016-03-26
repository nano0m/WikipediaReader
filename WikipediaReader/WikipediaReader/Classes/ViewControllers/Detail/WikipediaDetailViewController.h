//
//  WikipediaDetailViewController.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BookmarksViewController.h"
#import "Bookmark.h"

@interface WikipediaDetailViewController : BaseViewController<UIWebViewDelegate, UIPopoverPresentationControllerDelegate>


@property(weak, nonatomic) BookmarksViewController *delegate;
@property(strong, nonatomic) Bookmark *bookmark;

@end

