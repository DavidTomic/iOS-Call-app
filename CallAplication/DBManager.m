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

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;

@interface DBManager()
{
    NSString *databasePath;
}
@property (nonatomic, strong) NSMutableArray *arrResults;
@end

@implementation DBManager

+(DBManager*)sharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
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
            const char *sql_stmt_drive =
            "create table if not exists ContactTable (phoneNumber text, status integer, statusText text, endTime text)";
            if (sqlite3_exec(database, sql_stmt_drive, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create ContactTable");
            }
            
            const char *sql_stmt_drive_temp =
            "create table if not exists FavoritTable (phoneNumber text, favorit integer)";
            if (sqlite3_exec(database, sql_stmt_drive_temp, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create FavoritTable");
            }
//
//            const char *sql_stmt_myScore =
//            "create table if not exists myScoreTable (distanceWithoutSpeedingSum real, eligibleDiscount real, nextKm real, nextDiscount real, topDriverName text, topDriverDistance real)";
//            if (sqlite3_exec(database, sql_stmt_myScore, NULL, NULL, &errMsg)
//                != SQLITE_OK)
//            {
//                isSuccess = NO;
//                NSLog(@"Failed to create table");
//            }
//            
//            const char *sql_stmt_benefits =
//            "create table if not exists benefitsTable (km text, discount text)";
//            if (sqlite3_exec(database, sql_stmt_benefits, NULL, NULL, &errMsg)
//                != SQLITE_OK)
//            {
//                isSuccess = NO;
//                NSLog(@"Failed to create table");
//            }
            
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
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    
    // Set the database file path.
    //	NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Initialize the results array.
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
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
                        
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // Store each fetched data row in the results array, but first check if there is actually data.
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
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
}
-(NSArray *)loadDataFromDB:(NSString *)query{
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Returned the loaded results.
    return (NSArray *)self.arrResults;
}
-(void)executeQuery:(NSString *)query{
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

//my methods
-(NSArray *)getContactsFromDb{
    NSString *query = [NSString stringWithFormat:@"select * from ContactTable"];
    NSArray *contacts = [self loadDataFromDB:query];

    return contacts;
}


-(void)saveContactsToDb:(NSArray *)contactList{
    NSString *deleteQuery = @"delete from ContactTable";
    [self executeQuery:deleteQuery];
    
    for (Contact *contact in contactList){
        
        NSString *query = [NSString stringWithFormat:@"insert into ContactTable values('%@',%d,'%@','%@')", contact.phoneNumber, contact.status, contact.statusText,contact.endTime];
        [self executeQuery:query];
    }
}


@end
