//
//  DBManager.m
//  CallAplication
//
//  Created by David Tomic on 06/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import "DBManager.h"
#import "sqlite3.h"
#import "Contact.h"

NSString * const VERSION_KEY = @"version";

NSString * const CONTACT_TABLE = @"ContactTable";
NSString * const CONTACT_NAME_TABLE = @"ContactNameTable";
NSString * const DEFAULT_TEXT_TABLE = @"DefaultTextTable";
NSString * const FAVORIT_TABLE = @"FavoritTable";
NSString * const RECENT_TABLE = @"RecentTable";
NSString * const NOTIFICATION_TABLE = @"NotificationTable";

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;

@interface DBManager()
{
    NSString *databasePath;
}
//@property (nonatomic, strong) NSMutableArray *arrResults;
@end

@implementation DBManager

+(DBManager*)sharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
        [sharedInstance upgradeDatabaseIfRequired];
    }
    return sharedInstance;
}


-(BOOL)createDB{
    NSLog(@"createDB");
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"call.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            NSLog(@"OPEN");
            char *errMsg;
            const char *sql_stmt_ContactTable = [[NSString stringWithFormat:@"create table if not exists %@ (phoneNumber text)", CONTACT_TABLE]cStringUsingEncoding:NSASCIIStringEncoding];
            if (sqlite3_exec(database, sql_stmt_ContactTable, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create ContactTable");
            }
            
            const char *sql_stmt_ContactNameTable = [[NSString stringWithFormat:@"create table if not exists %@ (contactName text)", CONTACT_NAME_TABLE]cStringUsingEncoding:NSASCIIStringEncoding];
            if (sqlite3_exec(database, sql_stmt_ContactNameTable, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create ContactNameTable");
            }
            
            const char *sql_stmt_FavoritTable = [[NSString stringWithFormat:@"create table if not exists %@ (recordId integer)", FAVORIT_TABLE]cStringUsingEncoding:NSASCIIStringEncoding];
            if (sqlite3_exec(database, sql_stmt_FavoritTable, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create FAVORIT_TABLE");
            }
            
            const char *sql_stmt_RecentTable = [[NSString stringWithFormat:@"create table if not exists %@ (recordId integer, phoneNumber text, timestamp integer)", RECENT_TABLE] cStringUsingEncoding:NSASCIIStringEncoding];
            if (sqlite3_exec(database, sql_stmt_RecentTable, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create RECENT_TABLE");
            }
            
            const char *sql_stmt_DefaultTextTable = [[NSString stringWithFormat:@"create table if not exists %@ (Id INTEGER PRIMARY KEY, defaultText text)", DEFAULT_TEXT_TABLE] cStringUsingEncoding:NSASCIIStringEncoding];
            if (sqlite3_exec(database, sql_stmt_DefaultTextTable, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create DEFAULT_TEXT_TABLE");
            }
            
            const char *sql_stmt_notificationTable = [[NSString stringWithFormat:@"create table if not exists %@ (phoneNumber text, name text, status integer)", NOTIFICATION_TABLE] cStringUsingEncoding:NSASCIIStringEncoding];
            if (sqlite3_exec(database, sql_stmt_notificationTable, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create NOTIFICATION_TABLE");
            }
            
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }else{
        NSLog(@"DB EXISTS");
    }
    return isSuccess;
    
}
-(NSArray *)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    // Create a sqlite object.
   // NSLog(@"THREAD %@, QUERY %s", [NSThread currentThread], query);
        
    sqlite3 *sqlite3Database;
    
    // Set the database file path.
    //	NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Initialize the results array.
//    if (self.arrResults != nil) {
//        [self.arrResults removeAllObjects];
//        self.arrResults = nil;
//    }
//    self.arrResults = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
//    if (self.arrColumnNames != nil) {
//        [self.arrColumnNames removeAllObjects];
//        self.arrColumnNames = nil;
//    }
//    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
        
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            // Check if the query is non-executable.
            if (!queryExecutable){
                // In this case data must be loaded from the database.
                
                // Declare an array to keep the data for each fetched row.
                NSMutableArray *arrDataRow;
                
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++){
                        // Convert the column data to text (characters).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL) {
                            // Convert the characters to string.
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        
//                        // Keep the current column name.
//                        if (self.arrColumnNames.count != totalColumns) {
//                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
//                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
//                        }
                    }
                    
                    // Store each fetched data row in the results array, but first check if there is actually data.
                    if (arrDataRow.count > 0) {
                        [arrResults addObject:arrDataRow];
                    }
                }
            }
            else {
                // This is the case of an executable query (insert, update, ...).
                
                // Execute the query.
                if (sqlite3_step(compiledStatement)) {
                    // Keep the affected rows.
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID.
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }
                else {
                    // If could not execute the query show the error message on the debugger.
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        }
        else {
            // In the database cannot be opened then show the error message on the debugger.
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
        
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
        
    return arrResults;
}
-(NSArray *)loadDataFromDB:(NSString *)query{
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    return [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Returned the loaded results.
 //   return (NSArray *)self.arrResults;
}
-(void)executeQuery:(NSString *)query{
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}
- (NSString *)versionNumberString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return majorVersion;
}
-(void)upgradeDatabaseIfRequired{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *previousVersion=[defaults objectForKey:VERSION_KEY];
    NSString *currentVersion=[self versionNumberString];
    
    NSLog(@"previousVersion %@, currentVersion %@", previousVersion, currentVersion);
    
    
    if (previousVersion==nil || [previousVersion compare: currentVersion options: NSNumericSearch] == NSOrderedAscending) {
        // previous < current
        //read upgrade sqls from file
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"UpgradeDatabase" ofType:@"plist"];
        NSArray *plist = [NSArray arrayWithContentsOfFile:plistPath];
        
       // NSLog(@"plist %@", plist);
        
        if (previousVersion==nil) {//perform all upgrades
            for (NSDictionary *dictionary in plist) {
                NSString *version=[dictionary objectForKey:@"version"];
                NSLog(@"Upgrading to v. %@", version);
                NSArray *sqlQueries=[dictionary objectForKey:@"sql"];
                NSLog(@"sqlQueries %@", sqlQueries);
                for (int i=0; i<sqlQueries.count; i++) {
                    [self executeQuery:sqlQueries[i]];
                }
            }
        }else{
            for (NSDictionary *dictionary in plist) {
                NSString *version=[dictionary objectForKey:@"version"];
                if ([previousVersion compare: version options: NSNumericSearch] == NSOrderedAscending) {
                    //previous < version
                    NSLog(@"Upgrading to v. %@", version);
                    NSArray *sqlQueries=[dictionary objectForKey:@"sql"];
                    NSLog(@"sqlQueries %@", sqlQueries);
                    for (int i=0; i<sqlQueries.count; i++) {
                        [self executeQuery:sqlQueries[i]];
                    }
//                    while (![DB executeMultipleSql:sqlQueries]) {
//                        NSLog(@"Failed to upgrade database to v. %@, Retrying...", version);
//                    };
                }
                
            }
        }
        
        [defaults setObject:currentVersion forKey:VERSION_KEY];
        [defaults synchronize];
    }
    
}

-(void)addDefaultTextToDefaultTextDb:(NSString *)text{

    NSString *query = [NSString stringWithFormat:@"insert into %@ (defaultText) values('%@')", DEFAULT_TEXT_TABLE, text];
    
    [self executeQuery:query];
}
-(void)removeDefaultTextFromDefaultTextDb:(NSInteger)dtId{
    
    NSString *query = [NSString stringWithFormat:@"delete from %@ where Id=%ld",DEFAULT_TEXT_TABLE, (long)dtId];
    
    [self executeQuery:query];
}
-(NSArray *)getAllDefaultTextsFromDb{
    NSString *query = [NSString stringWithFormat:@"select * from %@", DEFAULT_TEXT_TABLE];
    NSArray *pom = [self loadDataFromDB:query];
    
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSArray * array in pom){
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:array[0] forKey:@"id"];
        [dict setObject:array[1] forKey:@"text"];
        [results addObject:dict];
    }
    
  //  NSLog(@"DEFAULT_TEXT_TABLE %@", results);
    
    return results;
}
-(void)saveDefaultTextsToDb:(NSArray *)textList{
    NSString *deleteQuery = [NSString stringWithFormat:@"delete from %@", DEFAULT_TEXT_TABLE];
    [self executeQuery:deleteQuery];

    for (NSString *text in textList){

        NSString *query = [NSString stringWithFormat:@"insert into %@ (defaultText) values('%@')", DEFAULT_TEXT_TABLE, text];
        [self executeQuery:query];
    }
}

-(void)addOrRemoveContactInFavoritWithRecordId:(int)recordId{
    NSString *query = [NSString stringWithFormat:@"select * from FavoritTable where recordId=%d", recordId];
    
    if([[self loadDataFromDB:query] count]>0){
        query = [NSString stringWithFormat:@"delete from FavoritTable where recordId=%d", recordId];
    }else{
        query = [NSString stringWithFormat:@"insert into FavoritTable values(%d)", recordId];
    }
    [self executeQuery:query];
}
-(NSArray *)getAllContactRecordIdsFromFavoritTable{
    NSString *query = [NSString stringWithFormat:@"select recordId from FavoritTable"];
    NSArray *results = [self loadDataFromDB:query];
    
    NSMutableArray *recordIdArray = [NSMutableArray array];
    
    for(NSMutableArray *array in results){
        NSNumber *recordId = @([array[0] integerValue]);
        [recordIdArray addObject:recordId];
    }
    
    return recordIdArray;
}


-(void)addContactInRecentWithRecordId:(int)recordId phoneNumber:(NSString *)phoneNumber timestamp:(long long)timestamp{
    
  //  NSLog(@"insert %d, phoneNumber %@, timestamp %lld", recordId, phoneNumber, timestamp);
    
    if (!recordId) {
        recordId=0;
    }else if (!phoneNumber) {
        phoneNumber=@"";
    }

     NSString *query = [NSString stringWithFormat:@"insert into RecentTable values(%d, '%@', %lld)", recordId, phoneNumber, timestamp];
    [self executeQuery:query];
}
-(void)deleteContactFromRecentWithRecordId:(int)recordId phoneNumber:(NSString *)phoneNumber timestamp:(long long)timestamp{
    
    NSString *query;
    
    if (recordId && recordId != 0) {
        query = [NSString stringWithFormat:@"delete from RecentTable where recordId=%d and timestamp=%lld", recordId, timestamp];
    }else {
        query = [NSString stringWithFormat:@"delete from RecentTable where phoneNumber='%@' and timestamp=%lld", phoneNumber, timestamp];
    }
    
    [self executeQuery:query];
}
-(NSArray *)getAllContactDataFromRecentTable{
    NSString *query = [NSString stringWithFormat:@"select * from RecentTable"];
    NSArray *results = [self loadDataFromDB:query];
    
 //   NSLog(@"getAllContactDataFromRecentTable result %@", results);
    
    return results;
}


-(void)addNotificationToDbWithPhoneNumber:(NSString *)phoneNumber name:(NSString *)name status:(Status)status{
    NSString *query = [NSString stringWithFormat:@"insert into %@ values('%@', '%@', %d)", NOTIFICATION_TABLE, phoneNumber, name, (int)status];
    [self executeQuery:query];
}
-(Notification *)getNotificationForPhoneNumber:(NSString *)phoneNumber{
    NSString *query = [NSString stringWithFormat:@"select * from %@ where phoneNumber = '%@'", NOTIFICATION_TABLE, phoneNumber];
    NSArray *pom = [self loadDataFromDB:query];
    
  //  NSLog(@"pom results %@", pom);
    
    if (pom.count > 0) {
        pom = pom[0];
        
      //  NSLog(@"pom[0] results %@", pom[0]);
        
        Notification *notification = [Notification new];
        notification.phoneNumber = pom[0];
        notification.name = pom[1];
        notification.status = [pom[2] integerValue];
        
        return notification;
    }
    
    return nil;
}
-(NSMutableArray *)getAllNotificationsFromDb{
    NSString *query = [NSString stringWithFormat:@"select * from %@", NOTIFICATION_TABLE];
    NSArray *pom = [self loadDataFromDB:query];
    
    NSMutableArray *results = [NSMutableArray new];
    
  //  NSLog(@"NOTIFICATION_TABLE %@", pom);
    
    for (NSArray *array in pom){
        Notification *notification = [Notification new];
        notification.phoneNumber = array[0];
        notification.name = array[1];
        notification.status = [array[2] integerValue];
        [results addObject:notification];
    }
    
  //  NSLog(@"NOTIFICATION_TABLE %@", results);
    
    return results;
}
-(void)removeNotificationFromDbWithPhoneNumber:(NSString *)phoneNumber{
    NSString *query = [NSString stringWithFormat:@"delete from NotificationTable where phoneNumber = '%@'", phoneNumber];
    [self executeQuery:query];
}


-(NSArray *)getTableList{
    NSString *query = [NSString stringWithFormat:@"select * from sqlite_master where type='table'"];
    NSArray *tables = [self loadDataFromDB:query];
    
    return tables;
}


@end
