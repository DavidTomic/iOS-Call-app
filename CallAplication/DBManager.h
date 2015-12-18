//
//  DBManager.h
//  CallAplication
//
//  Created by David Tomic on 06/08/15.
//  Copyright (c) 2015 David Tomic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"

@interface DBManager : NSObject

+(DBManager*)sharedInstance;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(void)addOrRemoveContactInFavoritWithRecordId:(int)recordId;
-(NSArray *)getAllContactRecordIdsFromFavoritTable;

-(void)addContactInRecentWithRecordId:(int)recordId phoneNumber:(NSString *)phoneNumber timestamp:(long long)timestamp;
-(void)deleteContactFromRecentWithRecordId:(int)recordId phoneNumber:(NSString *)phoneNumber timestamp:(long long)timestamp;
-(NSArray *)getAllContactDataFromRecentTable;

-(void)addDefaultTextToDefaultTextDb:(NSString *)text;
-(void)removeDefaultTextFromDefaultTextDb:(NSInteger)dtId;
-(NSArray *)getAllDefaultTextsFromDb;
-(void)saveDefaultTextsToDb:(NSArray *)textList;

-(void)addNotificationToDbWithPhoneNumber:(NSString *)phoneNumber name:(NSString *)name status:(Status)status;
-(Notification *)getNotificationForPhoneNumber:(NSString *)phoneNumber;
-(NSMutableArray *)getAllNotificationsFromDb;
-(void)removeNotificationFromDbWithPhoneNumber:(NSString *)phoneNumber;

//temp
-(NSArray *)getTableList;

@end
