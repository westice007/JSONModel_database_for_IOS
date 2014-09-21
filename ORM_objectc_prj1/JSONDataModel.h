//
//  JSONDataModel.h
//  ORM_objectc_prj1
//
//  Created by giganotebook10.9 on 14-9-20.
//  Copyright (c) 2014年 giganotebook10.9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@protocol IgnoreProper
@end


@interface JSONDataModel : NSObject{
    
}
@property(nonatomic,retain)NSDictionary* propertyDict;
@property(nonatomic,assign)int primaryKey;
//@property(nonatomic,retain)NSString* tableName;

-(void)addOneToBase;
-(void)updateOneToBase;
-(void)deleteOneFromBase;

-(NSMutableDictionary*)modelToDict;

+(JSONDataModel*)dictToModel:(NSMutableDictionary*)dict;

+(NSArray*)selectAll;
+(NSArray*)selectWhere:(NSString*)where;
+(NSArray*)selectWhere:(NSString*)where Order:(NSString*)order RowLimit:(int)rows;
+(void)updateWhere:(NSString*)where NewData:(JSONDataModel*)newModel;  //newModel 有值的属性将更新到 满足where的条目 
+(void)deleteWhere:(NSString*)where;


@end
