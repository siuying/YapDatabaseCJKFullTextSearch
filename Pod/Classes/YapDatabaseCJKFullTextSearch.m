//
//  YapDatabaseCJKFullTextSearch.m
//  Pods
//
//  Created by Francis Chong on 8/22/14.
//
//

#import "YapDatabaseCJKFullTextSearch.h"
#import "YapDatabaseFullTextSearchTransaction+CJK.h"
#import "JRSwizzle.h"

@interface YapDatabaseFullTextSearchTransaction(Private)
- (BOOL)createTable;
- (BOOL)prepareIfNeeded;
@end

@implementation YapDatabaseCJKFullTextSearch

+(void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [YapDatabaseFullTextSearchTransaction jr_swizzleMethod:@selector(createTable)
                                                    withMethod:@selector(cjk_createTable) error:nil];
        [YapDatabaseFullTextSearchTransaction jr_swizzleMethod:@selector(prepareIfNeeded)
                                                    withMethod:@selector(cjk_prepareIfNeeded) error:nil];
    });
}

- (id)initWithColumnNames:(NSArray *)columnNames
                  options:(NSDictionary *)options
                    block:(YapDatabaseFullTextSearchBlock)block
                blockType:(YapDatabaseFullTextSearchBlockType)blockType
                  version:(int)version
{
    NSMutableDictionary* newOptions = [options mutableCopy];
    [newOptions setObject:@"mozporter" forKey:@"tokenize"];
    return [super initWithColumnNames:columnNames
                              options:newOptions
                                block:block
                            blockType:blockType
                              version:version];
}

@end
