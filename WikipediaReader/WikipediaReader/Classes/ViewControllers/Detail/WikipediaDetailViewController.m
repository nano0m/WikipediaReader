//
//  WikipediaDetailViewController.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "WikipediaDetailViewController.h"
#import "Tools.h"
#import "WikipediaReaderDataManager.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface WikipediaDetailViewController ()

@property(weak, nonatomic) IBOutlet UIWebView *iboWikiWebView;

@property(strong, nonatomic) UIBarButtonItem *pAddToBookmarksButton;
@property(strong, nonatomic) UIBarButtonItem *pShareButton;
@property(strong, nonatomic) UIBarButtonItem *pRefreshButton;

#define RANDOM_WIKI_URL @"https://en.wikipedia.org/wiki/Special:Random"

@end

@implementation WikipediaDetailViewController

@synthesize bookmark = _bookmark;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.pShareButton = [[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                         target:self
                         action:@selector(shareButtonTapped:)];
    
    
    self.pAddToBookmarksButton = [[UIBarButtonItem alloc]
                                  initWithImage:[UIImage imageNamed:[self.bookmark isFavorite]? @"icn-btn-favorite-a":@"icn-btn-favorite"]
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(addToFavoritesButtonTapped:)];
    
    self.pRefreshButton = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                           target:self
                           action:@selector(refreshButtonTapped:)];
    
    self.navigationItem.rightBarButtonItems = @[self.pShareButton, self.pAddToBookmarksButton, self.pRefreshButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    if ([self.iboWikiWebView isLoading]) {
        [self.iboWikiWebView stopLoading];
    }
    
    self.bookmark = nil;
    self.pAddToBookmarksButton = nil;
    self.pShareButton = nil;
    self.pRefreshButton = nil;
}

- (void)setBookmark:(Bookmark *)bookmark{
    [self p_setAddToBookmarksButtonSelected:[bookmark isFavorite]];
    _bookmark = bookmark;
}

-(Bookmark*)bookmark{
    return _bookmark;
}

#pragma mark - Actions

- (void)refreshButtonTapped:(UIBarButtonItem*)item{
    NSLog(@"refreshButtonTapped");
    self.bookmark = nil;
    
    [self.delegate deselectBookmark];
    
    if ([self.iboWikiWebView isLoading]) {
        [self.iboWikiWebView stopLoading];
    }
    
    [self p_loadUrlString:nil];
}

- (void)shareButtonTapped:(UIBarButtonItem*)item{
    NSLog(@"shareButtonTapped");
    
    if (![Tools stringIsNullOrEmpty:self.bookmark.bookmarkTitle] && ![Tools stringIsNullOrEmpty:self.bookmark.bookmarkUrl]) {
        NSString *shareText = [[self.bookmark.bookmarkTitle stringByAppendingString:@"\n"] stringByAppendingString:self.bookmark.bookmarkUrl];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
        activityVC.excludedActivityTypes =  @[UIActivityTypeAssignToContact, UIActivityTypePostToWeibo, UIActivityTypePrint];
        
        if ( [activityVC respondsToSelector:@selector(popoverPresentationController)] ) {
            activityVC.popoverPresentationController.barButtonItem = self.pShareButton;
            activityVC.popoverPresentationController.delegate = self;
        }
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)addToFavoritesButtonTapped:(UIBarButtonItem*)item{
    NSLog(@"addToFavoritesButtonTapped");
    
    if (self.bookmark) {
        if (![self.bookmark isFavorite]) {
            NSString *email = nil;
            
            if ([GIDSignIn sharedInstance].currentUser.authentication != nil) {
                email = [[[[GIDSignIn sharedInstance] currentUser] profile] email];
            }
            
            self.bookmark = [[WikipediaReaderDataManager sharedManager] addBookmarkUrl:self.bookmark.bookmarkUrl
                                                                             withTitle:self.bookmark.bookmarkTitle
                                                                              forEmail:email];
        }else{
            [[WikipediaReaderDataManager sharedManager] removeBookmarkWithId:self.bookmark.bookmarkId];

            self.bookmark = [[Bookmark alloc] initWithBookmark:self.bookmark];
        }
        
        [self.delegate loadData];
    }
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (![self.bookmark isFavorite]) {
        self.bookmark = [[Bookmark alloc] init];
        self.bookmark.bookmarkTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.bookmark.bookmarkUrl = [[[webView request] URL] absoluteString];
    }
    
    [self setTitle:self.bookmark.bookmarkTitle];
    
    [self dataTransferCompleated:YES forView:self.view];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [super dataTransferCompleated:YES forView:self.view];
    
    if ([error code] != NSURLErrorCancelled) {
        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index"
                                                             ofType:@"html"
                                                        inDirectory:@"/Html" ];
        NSString *html = [NSString stringWithContentsOfFile:htmlPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        [self.iboWikiWebView loadHTMLString:html
                                    baseURL:[NSURL fileURLWithPath:
                                             [NSString stringWithFormat:@"%@/Html/",
                                              [[NSBundle mainBundle] bundlePath]]]];
        
    }
}

#pragma mark - Superclass methods

- (void)loadData{
    [super loadData];
    
    [self p_loadUrlString:self.bookmark.bookmarkUrl];
}

#pragma mark - Hidden methods

- (void)p_setAddToBookmarksButtonSelected:(BOOL)isSelected{
    self.pAddToBookmarksButton.image = [UIImage imageNamed:isSelected? @"icn-btn-favorite-a":@"icn-btn-favorite"];
}

- (void)p_loadUrlString:(NSString*)url{
    [self dataTransferCompleated:NO forView:self.view];
    
    NSString *urlString = url;
    
    if ([Tools stringIsNullOrEmpty:urlString]) {
        urlString = RANDOM_WIKI_URL;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.iboWikiWebView loadRequest:request];
}

#pragma mark - <UIPopoverPresentationControllerDelegate>

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    if (!traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return UIModalPresentationFullScreen;
    }
    
    if (self.splitViewController.view.bounds.size.width > 320) {
        return UIModalPresentationNone;
    } else {
        return UIModalPresentationFullScreen;
    }
}
@end
