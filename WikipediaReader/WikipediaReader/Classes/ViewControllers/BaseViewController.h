//
//  BaseViewController.h
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tools.h"

@interface BaseViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *iboActivityIndicatorView;

@property (assign, nonatomic) BOOL isDataAutoLoadDisabled;
@property (assign, nonatomic) BOOL isDataAutoLoaded;

- (void)addObservers;
- (void)applyLabels;
- (void)loadData;
- (void)applyStyles;
- (void)dataTransferCompleated:(BOOL)isEnabled forView:(UIView*)view;

@end
