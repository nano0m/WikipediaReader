//
//  LanguageViewController.m
//  WikipediaReader
//
//  Created by Arturs Rukmanis on 25.03.16.
//  Copyright © 2016 Arturs Rukmanis. All rights reserved.
//

#import "LanguageViewController.h"
#import "ListItemTableViewCell.h"

NSString *const kChangeLanguageSeagueId = @"ChangeLanguageSeagueId";

@interface LanguageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *iboLanguagesTableView;

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.iboLanguagesTableView registerNib:[UINib nibWithNibName:LIST_ITEM_TABLE_VIEW_CELL_NIB_DS[0] bundle:nil]
                     forCellReuseIdentifier:LIST_ITEM_TABLE_VIEW_CELL_NIB_DS[1]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSInteger idx =  [[[LocalizationSystem sharedLocalSystem] languagesSupportedByApplication] indexOfObject:AMLocalizationLanguage];
    
    [self.iboLanguagesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[LocalizationSystem sharedLocalSystem] languagesSupportedByApplication] count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LIST_ITEM_TABLE_VIEW_CELL_NIB_DS[1] forIndexPath:indexPath];
    NSString *langCode = [[[LocalizationSystem sharedLocalSystem] languagesSupportedByApplication] objectAtIndex:indexPath.row];
    
    cell.iboTitleLabel.text = AMLocalizedString(([NSString stringWithFormat:@"lbl_lang_%@", langCode]), @"");
    
    if (indexPath.row == ([[[LocalizationSystem sharedLocalSystem] languagesSupportedByApplication] count]-1) ) {
        [cell.iboSeparatorView setHidden:YES];
    }
    
    return cell;
}

#pragma mark <UITableViewDataSource>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSLog(@"LanguageViewController.didSelectRowAtIndexPath:%ld",(long)indexPath.row);
    
    NSString *langCode = [[[LocalizationSystem sharedLocalSystem] languagesSupportedByApplication] objectAtIndex:indexPath.row];
    
    if (![langCode isEqualToString:AMLocalizationLanguage]) {
        [Tools changeLanguageTo:langCode withNotification:YES];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Superclass methods

- (void)applyLabels{
    [super applyLabels];
}

@end
