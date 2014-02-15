//
//  ITYapDatabaseViewController.m
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 14/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import "ITYapDatabaseViewController.h"
#import "ITAppDelegate.h"
#import "ITPerson.h"
#import "ITTableViewCell.h"

@interface ITYapDatabaseViewController ()

@end

@implementation ITYapDatabaseViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initializeDb];
    }
    return self;
}

- (void)viewDidLoad
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    
    [super viewDidLoad];
    [self.tableView registerClass:[ITTableViewCell class] forCellReuseIdentifier:@"yap.database"];
    [self.searchDisplayController.searchResultsTableView registerClass:[ITTableViewCell class] forCellReuseIdentifier:@"yap.database"];
    
    [self updateNavigationBar];
}

- (void)updateNavigationBar
{
    self.navigationItem.title = @"YapDemo";
    if (self.activityIndicator.isAnimating)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    }
    else
        self.navigationItem.rightBarButtonItem = self.loadButtonItem;
}

- (IBAction)load:(id)sender
{
    [self.activityIndicator startAnimating];
    [self updateNavigationBar];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGFloat insertionTime = 0.0f;
        NSDate *referenceDate = [NSDate date];
        NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dummy" ofType:@"json"]];
        NSArray *people = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSLog(@"%@", [NSString stringWithFormat:@"Loaded people in %f sec", [[NSDate date] timeIntervalSinceDate:referenceDate]]);
        
        referenceDate = [NSDate date];

        
        [self.dbConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            
            [people enumerateObjectsUsingBlock:^(NSDictionary *info, NSUInteger idx, BOOL *stop) {
                
                ITPerson *person = [[ITPerson alloc] init];
                [person updateWithInfo:info];
                
                [transaction setObject:person forKey:person.udid inCollection:@"people"];
                NSString *log = [NSString stringWithFormat:@"Inserted %d of %d", idx, people.count];
                NSLog(@"%@", log);
            }];
        }];
        
        insertionTime = [[NSDate date] timeIntervalSinceDate:referenceDate];
        NSString *log = [NSString stringWithFormat:@"Insertions took %f sec", insertionTime];
        NSLog(@"%@", log);
        
        log = [NSString stringWithFormat:@"Took %f sec", insertionTime];
        NSLog(@"%@", log);


        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.activityIndicator stopAnimating];
            [self updateNavigationBar];
            [self.tableView reloadData];
        });
    });
    
}

- (NSString *)databaseName
{
	return @"YapDatabase.sqlite";
}

- (NSString *)databasePath
{
	return [[[[ITAppDelegate sharedInstance] applicationDocumentsDirectory] absoluteString] stringByAppendingPathComponent:[self databaseName]];
}

- (void)initializeDb
{
    self.db = [[YapDatabase alloc] initWithPath:[self databasePath]];
    self.dbConnection = [self.db newConnection];
    self.dbConnection.objectCacheLimit = 1000; // Most of the messages are maintained in the app
    YapDatabaseViewGroupingWithObjectBlock groupingBlock = ^NSString *(NSString *collection, NSString *key, ITPerson *person){
        
        return collection; // The group name is the name of the collection
    };
    
    YapDatabaseViewSortingWithObjectBlock sortingBlock = sortingBlock = ^(NSString *group, NSString *collection1, NSString *key1, ITPerson *person1, NSString *collection2, NSString *key2, ITPerson *person2){
        
        return [person1.name compare:person2.name];
    };
    
    self.dbView = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock groupingBlockType:YapDatabaseViewBlockTypeWithObject sortingBlock:sortingBlock sortingBlockType:YapDatabaseViewBlockTypeWithObject];
    [self.db registerExtension:self.dbView withName:@"people.collection"];
    
    [self initializeSearch];
}

- (void)initializeSearch
{
    NSArray *peopertiesToSearch = @[@"search.name", @"search.about"];
    YapDatabaseFullTextSearchWithObjectBlock searchBlock = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, ITPerson *person){
        [dict setObject:person.name forKey:@"search.name"];
        [dict setObject:person.about forKey:@"search.about"];
    };
    
    self.peopleSearch = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:peopertiesToSearch block:searchBlock blockType:YapDatabaseFullTextSearchBlockTypeWithObject];
    [self.db registerExtension:self.peopleSearch withName:@"people.search"];
}

-(void)filter:(NSString*)text
{
    [self.activityIndicator startAnimating];
    [self updateNavigationBar];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDate *referenceDate = [NSDate date];
        NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:100];
        [self.dbConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            [[transaction ext:@"people.search"] enumerateKeysAndObjectsMatching:[NSString stringWithFormat:@"%@*", text] usingBlock:^(NSString *collection, NSString *key, ITPerson *person, BOOL *stop) {
                
                [results addObject:person];
            }];
            
            NSString *log = [NSString stringWithFormat:@"Search took %f sec", [[NSDate date] timeIntervalSinceDate:referenceDate]];
            NSLog(@"%@", log);

            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.searchResults)
                    self.searchResults = [[NSMutableArray alloc] initWithCapacity:100];
                [self.activityIndicator stopAnimating];
                [self updateNavigationBar];
                [self.searchResults setArray:results];
                [self.tableView reloadData];
            });
        }];
    });
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if (text.length > 1)
        [self filter:text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.searchResults = nil;
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    __block NSInteger count = 1;

    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    __block NSInteger rows = 0;
    
    if (tableView == self.tableView)
    {
        [self.dbConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            rows = [transaction numberOfKeysInCollection:@"people"];
        }];
    }
    else
    {
        rows = self.searchResults.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yap.database" forIndexPath:indexPath];
    __block ITPerson *person = nil;

    if (tableView == self.tableView)
    {
        [self.dbConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            person = [[transaction ext:@"people.collection"] objectAtIndex:indexPath.row inGroup:@"people"];
            
        }];
    }
    else
        person = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[person valueForKey:@"name"] description];
    cell.detailTextLabel.text = [[person valueForKey:@"about"] description];

    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

@end
