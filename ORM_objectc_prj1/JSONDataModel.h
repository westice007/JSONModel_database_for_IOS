//
//  JSONDataModel.h
//  ORM_objectc_prj1
//
//  Created by giganotebook10.9 on 14-9-20.
//  Copyright (c) 2014年 giganotebook10.9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "PureJSONData.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
typedef void (^CustomVoidIntBlock)(int);

@interface BlockClass : NSObject

@property(nonatomic,retain)CustomVoidIntBlock voidintBlock;

@end


@interface JSONDataModel : PureJSONData{
    
}

@property(nonatomic,assign)int primaryKey;
@property(nonatomic,retain)BlockClass<IgnoreProper>* insertBlock;

//@property(nonatomic,retain)NSString* tableName;

+(FMDatabaseQueue*)shareFBDBQueue;

-(void)addOneToBase;
-(void)updateOneToBase;
-(void)deleteOneFromBase;

//-(void)updateOneToBaseWithKey:(NSString*)colName Value:(id)value;


-(NSString*)filterChars:(NSString*)srcStr;

+(JSONDataModel*)selectByPrimaryKey:(int)pKey;

+(void)createIndexForColumn:(NSString*)columnName;


+(NSArray*)selectAll;
+(NSArray*)selectAllByOrder:(NSString*)order;
+(NSArray*)selectAllByOrder:(NSString*)order RowLimit:(int)rows;
+(NSArray*)selectWhere:(NSString*)where;
+(NSArray*)selectWhere:(NSString*)where Order:(NSString*)order RowLimit:(int)rows;

+(NSArray*)selectWhere:(NSString*)where IgnoreColumns:(NSArray*)columns Order:(NSString*)order RowLimit:(int)rows;

//+(void)replaceWhere:(NSString*)where NewData:(JSONDataModel*)newModel;

+(void)updateWhere:(NSString*)where NewData:(JSONDataModel*)newModel;  //newModel 有值的属性将更新到 满足where的条目 
+(void)deleteWhere:(NSString*)where;

+(int)countWhere:(NSString*)where;

+(void)clearThisTable;

@end
