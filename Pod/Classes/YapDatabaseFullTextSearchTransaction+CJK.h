//
//  YapDatabaseCJKFullTextSearchTransaction.h
//  Pods
//
//  Created by Francis Chong on 8/22/14.
//
//

#import "YapDatabaseFullTextSearchTransaction.h"

@interface YapDatabaseCJKFullTextSearchTransaction: YapDatabaseFullTextSearchTransaction

-(BOOL) cjk_createTable;
-(BOOL) cjk_prepareIfNeeded;

@end
