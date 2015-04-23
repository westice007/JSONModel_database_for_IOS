//
//  PureJSONData.h
//  tukejiApp
//
//  Created by westiceFakeBigimac on 14-11-19.
//  Copyright (c) 2014年 lookfeel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define CONTAIN_STRING(lord,str) ( [lord rangeOfString:str].length > 0 )

@protocol IgnoreProper
@end

@protocol NSString
@end
@protocol NSNumber
@end

@interface PureJSONData : NSObject


@property(nonatomic,retain)NSDictionary* propertyDict;

+(PureJSONData*)model;

-(NSMutableDictionary*)modelToDict;
+(NSMutableDictionary*)getDictDictWithModelDict:(NSDictionary*)mDict;
+(NSMutableArray*)getDictArrayWithModelArray:(NSArray*)mArray;  //model数组转换成 dict数组
+(PureJSONData*)dictToModel:(NSMutableDictionary*)dict;
+(NSMutableArray*)dictArrayToModelArray:(NSMutableArray*)dArray;  //纯数组 转换成 model数组

-(void)absorbFromDict:(NSDictionary*)dict;

@end
