//
//  PureJSONData.m
//  tukejiApp
//
//  Created by westiceFakeBigimac on 14-11-19.
//  Copyright (c) 2014年 lookfeel. All rights reserved.
//

#import "PureJSONData.h"


@implementation PureJSONData
-(id)init{
    self = [super init];
    
    self.propertyDict = [self getPropertys];
    
    
    return self;
}


+(NSMutableDictionary*)getDictDictWithModelDict:(NSDictionary*)mDict{
    NSMutableDictionary* rDict = [NSMutableDictionary dictionaryWithCapacity:10];
    [mDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PureJSONData* tempModel = obj;
        [rDict setObject:[tempModel modelToDict] forKey:key];
    }];
    
    return rDict;
}

+(NSMutableArray*)dictArrayToModelArray:(NSMutableArray*)dArray{
    NSMutableArray* mArray = [NSMutableArray arrayWithCapacity:10];
    if ([dArray isKindOfClass:[NSArray class]]) {
        [dArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mArray addObject:[self dictToModel:obj]];
        }];
    }
    
    
    return mArray;
}

+(NSMutableDictionary*)dictDictToModelDict:(NSDictionary*)dDict{
    NSMutableDictionary* mDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [dDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [mDict setObject:[self dictToModel:obj] forKey:key];
    }];
    return mDict;
}

+(NSMutableArray*)getDictArrayWithModelArray:(NSArray*)mArray{
    NSMutableArray * rArray = [NSMutableArray arrayWithCapacity:10];
    if ([mArray isKindOfClass:[NSArray class]]) {
        [mArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PureJSONData* tempModel = obj;
            
            [rArray addObject:[tempModel modelToDict]];
        }];
    }
    
    return rArray;
}

-(NSMutableDictionary*)modelToDict{
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* colType = obj;
        id value = [self valueForKey:key];
        
        if ([value isKindOfClass:[NSNumber class]]) {
            [dict setObject:value forKey:key];
        }else if ([value isKindOfClass:[NSString class]]){
            [dict setObject:value forKey:key];
        }else if ([value isKindOfClass:[NSData class]]){
            [dict setObject:value forKey:key];
        }else if ([value isKindOfClass:[PureJSONData class]]){
            [dict setObject:[value modelToDict] forKey:key];
        }else if ([value isKindOfClass:[NSArray class]]){
            NSRange range0 = [colType rangeOfString:@"<"];
            NSRange range1 = [colType rangeOfString:@">"];
            NSString* objTypeStr = [colType substringWithRange:NSMakeRange(range0.location + 1, range1.location - range0.location - 1)];
            Class modelClass = NSClassFromString(objTypeStr);
            if ([modelClass isSubclassOfClass:[PureJSONData class]]) {
                [dict setObject:[modelClass getDictArrayWithModelArray:value] forKey:key];
            }else{
                //纯字典，不用递归
                [dict setObject:value forKey:key];
            }
            
        }else if ([value isKindOfClass:[NSDictionary class]]){
            NSRange range0 = [colType rangeOfString:@"<"];
            NSRange range1 = [colType rangeOfString:@">"];
            NSRange range2 = [colType rangeOfString:@"<" options:NSBackwardsSearch];
            NSRange range3 = [colType rangeOfString:@">" options:NSBackwardsSearch];
            NSString* objTypeStr0 = [colType substringWithRange:NSMakeRange(range0.location + 1, range1.location - range0.location - 1)];
            NSString* objTypeStr1 = [colType substringWithRange:NSMakeRange(range2.location + 1, range3.location - range2.location - 1)];

            Class modelClass = NSClassFromString(objTypeStr1);
            if ([modelClass isSubclassOfClass:[PureJSONData class]]) {
                [dict setObject:[modelClass getDictDictWithModelDict:value] forKey:key];
            }else{
                //纯字典，不用递归
                [dict setObject:value forKey:key];
            }
                
            
            //[dict setObject:[self.class getDictDictWithModelDict:value] forKey:key];
        }
        
        
        
    }];
    return dict;
}

+(PureJSONData*)dictToModel:(NSMutableDictionary*)dict{
    PureJSONData* tempM = [self model];
    [tempM absorbFromDict:dict];
    return tempM;
}

+(PureJSONData*)model{
    return [[self alloc] init];
}

-(void)absorbFromDict:(NSDictionary*)dict{
    [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* colType = obj;
        id value = nil;
        if ([dict isKindOfClass:[NSDictionary class]]) {
            value = [dict objectForKey:key];
        }
        
        
        if ([colType rangeOfString:@"NSString"].length > 0) {
            if (value != nil) {
                [self setValue:value forKey:key];
            }
        }else if ([colType rangeOfString:@"NSNumber"].length > 0){
            if (value != nil) {
                [self setValue:value forKey:key];
            }
        }else if (CONTAIN_STRING(obj,@"NSData") || CONTAIN_STRING(obj,@"NSMutableData")){
            if (value != nil) {
                [self setValue:value forKey:key];
            }
        }else if ([colType rangeOfString:@"NSArray"].length > 0){
            NSMutableArray* localArray = [self valueForKey:key];
            if (localArray == nil) {
                localArray = [NSMutableArray arrayWithCapacity:2]; //没有对象，就创建个。
            }
            if ([value isKindOfClass:[NSArray class]]) {
                //根据NSArray的范型遍历
                //找到泛型的类型
                NSRange range0 = [colType rangeOfString:@"<"];
                NSRange range1 = [colType rangeOfString:@">"];
                NSString* objTypeStr = [colType substringWithRange:NSMakeRange(range0.location + 1, range1.location - range0.location - 1)];
                if ([objTypeStr length] > 2) {
                    Class modelClass = NSClassFromString(objTypeStr);
                    if ([modelClass isSubclassOfClass:[PureJSONData class]]) {
                        //遍历value里面的值 转到 model
                        [localArray removeAllObjects];
                        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            id model = [modelClass model];
                            [model absorbFromDict:obj];
                            [localArray addObject:model];
                        }];
                        
                        
                    }else{
                        //纯数组，不用递归
                        
                        localArray = value;
                        
                    }
                    
                    
                }else{
                    NSLog(@"NSArray 没有泛型");
                }
                
            }else{
                //value没有值
               
            }
            [self setValue:localArray forKey:key];
            
        }else if ([colType rangeOfString:@"NSDictionary"].length > 0){
            NSMutableDictionary* localDict = [self valueForKey:key];
            if (localDict == nil) {
                localDict = [NSMutableDictionary dictionaryWithCapacity:2]; //没有对象，就创建个。
            }
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSRange range0 = [colType rangeOfString:@"<"];
                NSRange range1 = [colType rangeOfString:@">"];
                NSRange range2 = [colType rangeOfString:@"<" options:NSBackwardsSearch];
                NSRange range3 = [colType rangeOfString:@">" options:NSBackwardsSearch];
                NSString* objTypeStr0 = [colType substringWithRange:NSMakeRange(range0.location + 1, range1.location - range0.location - 1)];
                NSString* objTypeStr1 = [colType substringWithRange:NSMakeRange(range2.location + 1, range3.location - range2.location - 1)];
                
                if ([objTypeStr0 length] > 2 && [objTypeStr1 length] > 2) {
                    //将value 合并到 localDict
                    Class modelClass = NSClassFromString(objTypeStr1);
                    if ([modelClass isSubclassOfClass:[PureJSONData class]]) {
                        //遍历value里面有用的值 转成model 合并到 localDict
                        [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            id localModel = [localDict valueForKey:key];
                            if (localModel == nil) {
                                localModel = [modelClass model];
                            }
                            [localModel absorbFromDict:obj];
                            [localDict setValue:localModel forKey:key];
                        }];
                    }else{
                        //纯字典，不用递归
                        if (value != nil) {
                            [localDict setValuesForKeysWithDictionary:value];
                        }
                    }
                    
                    
                }else{
                    NSLog(@"NSDictionary 没有泛型");
                }
                
                
            }else{
                //NSLog(@"json 不是字典");
                //value没有值，不做事。
            }
            [self setValue:localDict forKey:key];
            
        }else{
            //其它类型
            
            Class typeClass = NSClassFromString(colType);
            //NSLog(@"其它类型 ...%@",typeClass);
            if ([typeClass isSubclassOfClass:[PureJSONData class]]) {
                id localModel = [self valueForKey:key];
                if (localModel == nil) {
                    localModel = [typeClass model];
                }
                
                //将value合并到localModel
                [localModel absorbFromDict:value];
                [self setValue:localModel forKey:key];
            }
            
            
        }
        
        
    }];
}


-(NSDictionary*)getPropertys{
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:30];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * cname = property_getName(property);
        char * ctype = property_copyAttributeValue(property, "T");
        NSString* propertyName = [NSString stringWithUTF8String:cname];
        NSString* type = [NSString stringWithUTF8String:ctype];
        type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        type = [type stringByReplacingOccurrencesOfString:@"@" withString:@""];
        if ([type rangeOfString:@"IgnoreProper"].length > 0) {
            continue;
        }
        if ([type rangeOfString:@"NSNumber"].length > 0) {
            
        }
        //NSLog(@"propertyName:%@",propertyName);
        //NSLog(@"type:%@",type);
        [result setObject:type forKey:propertyName];
    }
    free(properties);
    //return propertyNamesArray;
    return result;
}

-(NSString*)description{
    NSMutableString* desc = [NSMutableString stringWithFormat:@"%@: [",NSStringFromClass([self class])];
    
    [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* colType = obj;
        id value = [self valueForKey:key];
        [desc appendFormat:@"%@<%@> = %@  \r",key,colType,value];
    }];
    [desc appendString:@"]"];
    return desc;
}


@end
