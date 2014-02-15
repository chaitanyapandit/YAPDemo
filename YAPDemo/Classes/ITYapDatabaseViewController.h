//
//  ITYapDatabaseViewControlle.h
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 14/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Yapdatabase/YapDatabase.h>
#import <Yapdatabase/YapDatabaseView.h>
#import <Yapdatabase/YapDatabaseFullTextSearch.h>

@interface ITYapDatabaseViewController : UITableViewController

@property (nonatomic, strong) YapDatabase *db;
@property (nonatomic, strong) YapDatabaseConnection *dbConnection;
@property (nonatomic, strong) YapDatabaseView *dbView;
@property (nonatomic, strong) YapDatabaseFullTextSearch *peopleSearch;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loadButtonItem;

- (IBAction)load:(id)sender;

@end
