//
//  BaseViewController.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addObservers];
    [self applyLabels];
    [self applyStyles];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!self.isDataAutoLoadDisabled &&  !self.isDataAutoLoaded) {
        [self loadData];
        self.isDataAutoLoaded = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)appLanguageChangedNotification:(NSNotification *)notification {
    [self applyLabels];
}

#pragma mark - Superclass methods

- (void)addObservers{
    //override in subclass
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appLanguageChangedNotification:)
                                                 name:kApplicationLanguageChangedNotification
                                               object:nil];
}

- (void)applyLabels{
    //override in subclass
}

-(void)loadData{
    //override in subclass
}

-(void)applyStyles{
    
}

- (void)dataTransferCompleated:(BOOL)isEnabled forView:(UIView*)view{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = !isEnabled;
    
    if (self.iboActivityIndicatorView) {
        if (isEnabled) {
            [self.iboActivityIndicatorView stopAnimating];
        }else{
            [self.iboActivityIndicatorView startAnimating];
        }
    }
    
    [view setUserInteractionEnabled:isEnabled];
}

@end
