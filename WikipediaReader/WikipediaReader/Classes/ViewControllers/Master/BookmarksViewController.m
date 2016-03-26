//
//  BookmarksViewController.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "BookmarksViewController.h"
#import "LocalizationSystem.h"
#import "WikipediaReaderDataManager.h"
#import "BookmarkTableViewCell.h"
#import "WikipediaDetailViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>

NSString *const kShowWikiDetailsSegueId = @"ShowWikiDetailsSegueId";
NSString *const kShowBookmarkWikiDetailsSegueId = @"ShowBookmarkWikiDetailsSegueId";

@interface BookmarksViewController ()

@property(strong, nonatomic) UIBarButtonItem *pWikiDetailsButton;
@property(strong, nonatomic) NSMutableArray<Bookmark*> *pBookmarks;
@property(strong, nonatomic) WikipediaDetailViewController *pWikiDetails;
@property (weak, nonatomic) IBOutlet UITableView *iboBookmarksTableView;
@property (weak, nonatomic) IBOutlet UIButton *iboPublicBookmarksButton;
@property (weak, nonatomic) IBOutlet UIButton *iboMyBookmarksButon;
@property (weak, nonatomic) IBOutlet UILabel *iboNoDataMessage;
@property (weak, nonatomic) IBOutlet UILabel *iboSignInLabel;

@end

@implementation BookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataTransferCompleated:NO forView:nil];
    
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    self.pWikiDetails = (WikipediaDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.pWikiDetails.delegate = self;
    
    self.pWikiDetailsButton = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                               target:self
                               action:@selector(wikiDetailsButtonTapped:)];
    
    [self.iboBookmarksTableView registerNib:[UINib nibWithNibName:BOOKMARK_TABLE_VIEW_CELL_NIB_DS[0] bundle:nil]
                     forCellReuseIdentifier:BOOKMARK_TABLE_VIEW_CELL_NIB_DS[1]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self p_setHiddenRightButton:!self.splitViewController.isCollapsed];
    [self p_checkNoData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deselectBookmark{
    [self.iboBookmarksTableView deselectRowAtIndexPath:[self.iboBookmarksTableView indexPathForSelectedRow] animated:YES];
}

- (void)dealloc{
    self.pWikiDetailsButton = nil;
    self.pBookmarks = nil;
    self.pWikiDetails = nil;
}

#pragma mark - Actions

- (IBAction)publicBookmarksTapped:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = !sender.selected;
    }
    self.iboMyBookmarksButon.selected = NO;
    
    [self loadData];
}

- (IBAction)myBookmarksTapped:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = !sender.selected;
    }
    self.iboPublicBookmarksButton.selected = NO;
    
    [self loadData];
}

- (void)wikiDetailsButtonTapped:(UIBarButtonItem*)item{
    [self performSegueWithIdentifier:kShowWikiDetailsSegueId sender:nil];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.pBookmarks count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BOOKMARK_TABLE_VIEW_CELL_NIB_DS[1] forIndexPath:indexPath];
    
    Bookmark *bookmark = [self.pBookmarks objectAtIndex:indexPath.row];
    cell.iboTitleLabel.text = bookmark.bookmarkTitle;
    [cell.iboTitleLabel sizeToFit];
    
    cell.iboDateLabel.text = [Tools dateToString:bookmark.bookmarkDate];
    
    if (indexPath.row == ([self.pBookmarks count]-1) ) {
        [cell.iboSeparatorView setHidden:YES];
    }
    
    return cell;
}

#pragma mark - <UITableViewDataSource>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSLog(@"BookmarksViewController.didSelectRowAtIndexPath:%ld",(long)indexPath.row);
    
    [self performSegueWithIdentifier:kShowBookmarkWikiDetailsSegueId sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BOOL isLastRow = ([self.pBookmarks count] - 1) == indexPath.row;
        Bookmark *bookmark = [self.pBookmarks objectAtIndex:indexPath.row];
        [[WikipediaReaderDataManager sharedManager] removeBookmarkWithId:bookmark.bookmarkId];
        
        [self.pBookmarks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (isLastRow && indexPath.row-1 >= 0) {
            BookmarkTableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
            [cell.iboSeparatorView setHidden:YES];
        }
        
        self.pWikiDetails.bookmark = [[Bookmark alloc] initWithBookmark:bookmark];
        
        [self p_checkNoData];
    }
}

#pragma mark - Hidden methods

- (void)p_checkNoData{
    self.iboSignInLabel.hidden = YES;
    
    if (self.iboMyBookmarksButon.selected) {
        if ([GIDSignIn sharedInstance].currentUser.authentication != nil) {
            self.iboNoDataMessage.hidden = [self.pBookmarks count] > 0;
        }else{
            self.iboNoDataMessage.hidden = YES;
            self.iboSignInLabel.hidden = NO;
        }
    }else{
        self.iboNoDataMessage.hidden = [self.pBookmarks count] > 0;
    }

}

- (void)p_setHiddenRightButton:(BOOL)isHidden {
    if (isHidden) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.pWikiDetailsButton;
    }
}

#pragma mark - Superclass methods

- (void)applyLabels{
    [super applyLabels];
    
    [self.iboPublicBookmarksButton setTitle:AMLocalizedString(@"lbl_public_bookmarks", @"") forState:UIControlStateNormal];
    [self.iboMyBookmarksButon setTitle:AMLocalizedString(@"lbl_my_bookmarks", @"") forState:UIControlStateNormal];
    
    [self setTitle:AMLocalizedString(@"title_bookmarks", @"")];
    
    [self.iboNoDataMessage setText:AMLocalizedString(@"title_no_data", @"")];
    [self.iboSignInLabel setText:AMLocalizedString(@"title_sign_in_to_view", @"")];
}

- (void)loadData{
    [super loadData];
    [self dataTransferCompleated:YES forView:nil];
    
    
    if (!self.isDataAutoLoaded && [GIDSignIn sharedInstance].currentUser.authentication != nil) {
        self.iboPublicBookmarksButton.selected = NO;
        self.iboMyBookmarksButon.selected = YES;
    }
    
    if (self.iboMyBookmarksButon.selected) {
        if ([GIDSignIn sharedInstance].currentUser.authentication != nil) {
            self.pBookmarks = [[WikipediaReaderDataManager sharedManager] loadBookmarksForEmail:[[[[GIDSignIn sharedInstance] currentUser] profile] email]];
        }else{
            [self.pBookmarks removeAllObjects];
        }
        
        
    }else{
        self.pBookmarks = [[WikipediaReaderDataManager sharedManager] loadBookmarksForEmail:nil];
    }
    
    [self p_checkNoData];
    
    [self.iboBookmarksTableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = segue.destinationViewController;
        
        if ([nav.topViewController isKindOfClass:[WikipediaDetailViewController class]]) {
            self.pWikiDetails = (WikipediaDetailViewController*)nav.topViewController;
            self.pWikiDetails.delegate = self;
            
            if ([segue.identifier isEqualToString:kShowBookmarkWikiDetailsSegueId]) {
                self.pWikiDetails.bookmark = [self.pBookmarks objectAtIndex:[self.iboBookmarksTableView.indexPathForSelectedRow row]];
            }
        }
    }
}

@end
