//
//  YapDatabaseCJKFullTextSearch.h
//  Pods
//
//  Created by Francis Chong on 8/22/14.
//
//

#import <Foundation/Foundation.h>
#import "YapDatabaseFullTextSearch.h"

@interface YapDatabaseCJKFullTextSearch : YapDatabaseFullTextSearch

- (id)initWithColumnNames:(NSArray *)columnNames
                  options:(NSDictionary *)options
                    block:(YapDatabaseFullTextSearchBlock)block
                blockType:(YapDatabaseFullTextSearchBlockType)blockType
                  version:(int)version;

@end