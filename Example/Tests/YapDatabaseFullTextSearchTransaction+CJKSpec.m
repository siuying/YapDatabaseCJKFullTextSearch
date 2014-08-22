//
//  YapDatabaseCJKFullTextSearchTests.m
//  YapDatabaseCJKFullTextSearchTests
//
//  Created by Francis Chong on 08/22/2014.
//  Copyright (c) 2014 Francis Chong. All rights reserved.
//
#import "YapDatabase.h"
#import "YapDatabaseFullTextSearch.h"
#import "YapDatabaseCJKFullTextSearch.h"

SPEC_BEGIN(YapDatabaseFullTextSearchTransaction_CJKSpec)

NSString*(^DatabasePath)(NSString*) = ^(NSString* prefix){
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString* filename = [NSString stringWithFormat:@"%@-db.sqlite", prefix];
    return [baseDir stringByAppendingPathComponent:filename];
};

YapDatabase*(^ConfigureDatabase)(NSString*, Class) = ^(NSString* databasePath, Class connectionClass){
    YapDatabase* database = [[YapDatabase alloc] initWithPath:databasePath];

    YapDatabaseFullTextSearchBlockType blockType = YapDatabaseFullTextSearchBlockTypeWithObject;
    YapDatabaseFullTextSearchWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
        [dict setObject:object forKey:@"content"];
    };

    YapDatabaseFullTextSearch *fts = [[connectionClass alloc] initWithColumnNames:@[@"content"]
                                                                          options:@{}
                                                                            block:block
                                                                        blockType:blockType
                                                                          version:1];
    [database registerExtension:fts withName:@"fts"];
    return database;
};

void(^InsertData)(YapDatabaseConnection*) = ^(YapDatabaseConnection* connection){
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:@"hello world" forKey:@"key1" inCollection:nil];
        [transaction setObject:@"你好世界" forKey:@"key2" inCollection:nil];
        [transaction setObject:@"hello laptop" forKey:@"key3" inCollection:nil];
        [transaction setObject:@"hello work" forKey:@"key4" inCollection:nil];
        [transaction setObject:@"你好工作" forKey:@"key5" inCollection:nil];
    }];
};

describe(@"YapDatabaseFullTextSearchTransaction+CJK", ^{
    __block YapDatabase* database;
    __block YapDatabaseConnection* connection;

    context(@"without mozporter tokenizer", ^{
        beforeEach(^{
            NSString *databasePath = DatabasePath(@"no-mozporter");
            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:NULL];
            database = ConfigureDatabase(databasePath, [YapDatabaseFullTextSearch class]);
            connection = [database newConnection];
            InsertData(connection);
        });
        
        it(@"should not search chinese message", ^{
            [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                __block NSUInteger count;
                // Find matches for: hello
                count = 0;
                [[transaction ext:@"fts"] enumerateKeysMatching:@"hello"
                                                     usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
                                                         count++;
                                                     }];
                [[theValue(count) should] equal:theValue(3)];
                
                count = 0;
                [[transaction ext:@"fts"] enumerateKeysMatching:@"你好"
                                                     usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
                                                         count++;
                                                     }];
                [[theValue(count) should] equal:theValue(0)];
            }];
        });
    });

    context(@"with mozporter tokenizer", ^{
        beforeEach(^{
            NSString *databasePath = DatabasePath(@"mozporter");
            [[NSFileManager defaultManager] removeItemAtPath:databasePath error:NULL];
            database = ConfigureDatabase(databasePath, [YapDatabaseCJKFullTextSearch class]);
            connection = [database newConnection];
            InsertData(connection);
        });

        it(@"should search chinese message", ^{
            [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                __block NSUInteger count;
                // Find matches for: hello
                count = 0;
                [[transaction ext:@"fts"] enumerateKeysMatching:@"hello"
                                                     usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
                                                         count++;
                                                     }];
                [[theValue(count) should] equal:theValue(3)];
                
                count = 0;
                [[transaction ext:@"fts"] enumerateKeysMatching:@"你好"
                                                     usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
                                                         count++;
                                                     }];
                [[theValue(count) should] equal:theValue(2)];
            }];
        });
    });

});

SPEC_END
