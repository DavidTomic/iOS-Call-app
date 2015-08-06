//
//  DBManager.h
//  CallAplication
//
//  Created by David Tomic on 06/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

+(DBManager*)sharedInstance;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(NSArray *)getContactsFromDb;
-(void)saveContactsToDb:(NSArray *)contactList;

@end
