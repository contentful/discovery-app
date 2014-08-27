//
//  CDAPreviousSpacesViewController.m
//  Discovery
//
//  Created by Boris Bügling on 26/08/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDAPreviouslySelectedSpace.h"
#import "CDAPreviousSpacesViewController.h"
#import "CDAPrimitiveCell.h"
#import "CDASpaceSelectionViewController.h"

@interface CDAPreviousSpacesViewController ()

@property (nonatomic) RLMArray* spaces;

@end

#pragma mark -

@implementation CDAPreviousSpacesViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    if ([CDAPreviouslySelectedSpace allObjects].count == 0) {
        [CDAPreviouslySelectedSpace spaceWithAccessToken:@"af972a4929249ff278fa09828a4f6d4580ff6cba1d0ca1ef12c0c9afda2fe57e" name:@"Demo Space"numberOfEntries:17 spaceKey:@"nvyqx9l6z9z9"];
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
    self.title = NSLocalizedString(@"Space History", nil);

    [self.tableView registerClass:[CDAPrimitiveCell class]
           forCellReuseIdentifier:NSStringFromClass(self.class)];

    self.spaces = [[CDAPreviouslySelectedSpace allObjects] arraySortedByProperty:@"lastAccessTime"
                                                                       ascending:NO];
}

#pragma mark - Actions

-(void)doneTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)
                                                            forIndexPath:indexPath];

    CDAPreviouslySelectedSpace* space = self.spaces[indexPath.row];

    cell.textLabel.text = space.name;
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:space.lastAccessTime
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterShortStyle];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.spaces.count;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CDAPreviouslySelectedSpace* space = self.spaces[indexPath.row];

    [[NSUserDefaults standardUserDefaults] setValue:space.accessToken forKey:CDAAccessTokenKey];
    [[NSUserDefaults standardUserDefaults] setValue:space.spaceKey forKey:CDASpaceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
