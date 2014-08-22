//
//  IGViewController.m
//  YapDatabaseCJKFullTextSearch
//
//  Created by Francis Chong on 08/22/2014.
//  Copyright (c) 2014 Francis Chong. All rights reserved.
//

#import "IGViewController.h"
#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseFullTextSearch.h>

#import "YapDatabaseCJKFullTextSearch.h"

@interface IGViewController()
@property (nonatomic, strong) YapDatabase* database;
@end

@implementation IGViewController

-(void) setupDatabase
{
    NSString *databasePath = [self databasePathWithName:@"sample"];
    [[NSFileManager defaultManager] removeItemAtPath:databasePath error:NULL];
    
    self.database = [[YapDatabase alloc] initWithPath:databasePath];

    YapDatabaseFullTextSearchBlockType blockType = YapDatabaseFullTextSearchBlockTypeWithObject;
    YapDatabaseFullTextSearchWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
        [dict setObject:object forKey:@"content"];
    };

    YapDatabaseFullTextSearch *fts = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:@[@"content"]
                                                                                    options:@{@"tokenize": @"mozporter"}
                                                                                      block:block
                                                                                  blockType:blockType
                                                                                    version:1];
    [self.database registerExtension:fts withName:@"fts"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDatabase];

    YapDatabaseConnection *connection = [self.database newConnection];
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:@"hello world" forKey:@"key1" inCollection:nil];
        [transaction setObject:@"你好世界" forKey:@"key2" inCollection:nil];
        [transaction setObject:@"hello laptop" forKey:@"key3" inCollection:nil];
        [transaction setObject:@"hello work" forKey:@"key4" inCollection:nil];
        [transaction setObject:@"你好工作" forKey:@"key5" inCollection:nil];
    }];
    
    [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        __block NSUInteger count;
        // Find matches for: hello
        count = 0;
        [[transaction ext:@"fts"] enumerateKeysMatching:@"hello"
                                             usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
                                                 count++;
                                             }];
        NSLog(@"expect 3 item, currently: %@", @(count));

        count = 0;
        [[transaction ext:@"fts"] enumerateKeysMatching:@"你好"
                                             usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
                                                 count++;
                                             }];
        NSLog(@"expect 2 item, currently: %@", @(count));
    }];
}

- (NSString *)databasePathWithName:(NSString *)suffix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *databaseName = [NSString stringWithFormat:@"%@-%@.sqlite", @"tweet", suffix];
    return [baseDir stringByAppendingPathComponent:databaseName];
}

@end
