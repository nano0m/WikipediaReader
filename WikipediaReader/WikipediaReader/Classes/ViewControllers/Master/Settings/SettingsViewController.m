//
//  SettingsViewController.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "SettingsViewController.h"
#import "ListItemTableViewCell.h"
#import "LanguageViewController.h"

@interface SettingsViewController ()<GIDSignInDelegate, GIDSignInUIDelegate>

@property (weak, nonatomic) IBOutlet UITableView *iboSettingsTableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    
    [self.iboSettingsTableView registerNib:[UINib nibWithNibName:LIST_ITEM_TABLE_VIEW_CELL_NIB_DS[0] bundle:nil]
                    forCellReuseIdentifier:LIST_ITEM_TABLE_VIEW_CELL_NIB_DS[1]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Superclass methods

- (void)applyLabels{
    [super applyLabels];
    
    [self.iboSettingsTableView reloadData];
    [self setTitle:AMLocalizedString(@"title_settings", @"")];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LIST_ITEM_TABLE_VIEW_CELL_NIB_DS[1] forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        if ([GIDSignIn sharedInstance].currentUser.authentication != nil){
            cell.iboTitleLabel.text = [NSString stringWithFormat:AMLocalizedString(@"title_settings_signout", @""), [[[[GIDSignIn sharedInstance] currentUser]profile]name]];
        }else{
            cell.iboTitleLabel.text = AMLocalizedString(@"title_settings_signin", @"");
        }
    }else if (indexPath.row == 1) {
        cell.iboTitleLabel.text = AMLocalizedString(@"title_settings_change_language", @"");
        [cell.iboSeparatorView setHidden:YES];
    }
    
    return cell;
}

#pragma mark <UITableViewDataSource>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:kChangeLanguageSeagueId sender:nil];
    }else{
        if ([GIDSignIn sharedInstance].currentUser.authentication != nil){
            [[GIDSignIn sharedInstance] disconnect];
        }else{
            [[GIDSignIn sharedInstance] signIn];
        }
    }
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (!error) {
        NSLog(@"Status: Authentication success for user: %@", [user.profile name]);
        
    }else{
        NSLog(@"Status: Authentication error: %@", error);
    }
    
    [(BaseViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2] loadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        NSLog(@"Status: Failed to disconnect: %@", error);
    }else{
        NSLog(@"Status: Disconnected");
    }
    [(BaseViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2] loadData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
