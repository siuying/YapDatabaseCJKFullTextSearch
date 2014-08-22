//
//  YapDatabaseCJKFullTextSearchTransaction.m
//  Pods
//
//  Created by Francis Chong on 8/22/14.
//
//

#import "YapDatabaseFullTextSearchTransaction+CJK.h"
#import "YapDatabaseFullTextSearchPrivate.h"
#import "YapDatabasePrivate.h"
#import "YapDatabaseCJKFullTextSearch.h"

#import "sqlite3.h"
#import "fts3_tokenizer.h"

@interface YapDatabaseFullTextSearchTransaction(Private)
- (NSString *)tableName;
- (NSString *)registeredName;
@end

const static sqlite3_tokenizer_module* module;

void sqlite3Fts3PorterTokenizerModule(sqlite3_tokenizer_module const**ppModule);

int sqlite3RegisterTokenizer(sqlite3 *db, char *zName, const sqlite3_tokenizer_module *p){
    int rc;
    sqlite3_stmt *pStmt;
    const char *zSql = "SELECT fts3_tokenizer(?, ?)";
    
    rc = sqlite3_prepare_v2(db, zSql, -1, &pStmt, 0);
    if( rc != SQLITE_OK ){
        return rc;
    }
    
    sqlite3_bind_text(pStmt, 1, zName, -1, SQLITE_STATIC);
    sqlite3_bind_blob(pStmt, 2, &p, sizeof(p), SQLITE_STATIC);
    rc = sqlite3_step(pStmt);
    if (rc != SQLITE_DONE && rc != SQLITE_ROW) {
        return rc;
    }
    
    return sqlite3_finalize(pStmt);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation YapDatabaseFullTextSearchTransaction (CJK)

- (BOOL) cjk_createTable
{
    [self preloadMozPorterIfNeeded];
    return [self cjk_createTable];
}

-(BOOL) cjk_prepareIfNeeded
{
    [self preloadMozPorterIfNeeded];
    return YES;
}

-(void) preloadMozPorterIfNeeded
{
    if ([ftsConnection.fullTextSearch isKindOfClass:[YapDatabaseCJKFullTextSearch class]]) {
        sqlite3 *db = databaseTransaction->connection->db;
        sqlite3Fts3PorterTokenizerModule(&module);
        sqlite3RegisterTokenizer(db, "mozporter", module);
    }
}

@end