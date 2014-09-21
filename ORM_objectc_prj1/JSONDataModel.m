//
//  JSONDataModel.m
//  ORM_objectc_prj1
//
//  Created by giganotebook10.9 on 14-9-20.
//  Copyright (c) 2014年 giganotebook10.9. All rights reserved.
//

#import "JSONDataModel.h"
#import <objc/runtime.h>



@implementation JSONDataModel{
    
}

static sqlite3 *JSONDataModelDatabase = nil;
static NSMutableDictionary* tableNamesCheckedDict = nil;

-(id)init{
    self = [super init];
    
    self.propertyDict = [self getPropertys];
    
    if (JSONDataModelDatabase == nil) {
        [self initDataBase];
    }
    
    [self createOrUpdateTable];
    
    return self;
}

-(void)initDataBase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* basePath = [documentsDirectory stringByAppendingPathComponent:@"JSONDataModelDatabase.sqlite3"];
    NSLog(@"JSONDataModelDatabase basePath:%@",basePath);
    if (sqlite3_open([basePath UTF8String], &JSONDataModelDatabase) != SQLITE_OK) {
        sqlite3_close(JSONDataModelDatabase);
        
    }
    
    tableNamesCheckedDict = [NSMutableDictionary dictionaryWithCapacity:20];
    
}

+(NSString*)tableName{
    return NSStringFromClass([self class]);
}

-(void)createOrUpdateTable{
    //检查表的结构，创建或者更新字段
    NSString* checked = [tableNamesCheckedDict objectForKey:[self.class tableName]];
    if ([checked intValue] == 0) {
        
        //NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS TestModel (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, address TEXT)";
        
        NSMutableString* sqlCreate = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (primaryKey INTEGER PRIMARY KEY AUTOINCREMENT,",[self.class tableName]];
        
        __block BOOL first = YES;
        [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString* colType = @"";
            if ([obj rangeOfString:@"NSString"].length > 0) {
                colType = @"TEXT";
            }else if ([obj rangeOfString:@"NSNumber"].length > 0){
                colType = @"NUMERIC";
            }
            if (first) {
                [sqlCreate appendFormat:@"%@ %@",key,colType];
            }else{
                [sqlCreate appendFormat:@",%@ %@",key,colType];
            }
            first = NO;
        }];
        [sqlCreate appendString:@")"];
        NSLog(@"sqlCreate:%@",sqlCreate);
        
        char *err;
        if (sqlite3_exec(JSONDataModelDatabase, [sqlCreate UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            sqlite3_close(JSONDataModelDatabase);
            NSLog(@"数据库创建表失败!");
        }
        

        
        NSMutableDictionary* allColumnType = [NSMutableDictionary dictionaryWithCapacity:10];
        sqlite3_stmt * statement;
        int rc = sqlite3_prepare_v2(JSONDataModelDatabase, "PRAGMA table_info ('TestModel')", -1, &statement, NULL);
        
        if (rc==SQLITE_OK)
        {
            //will continue to go down the rows (columns in your table) till there are no more
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                int columnCount = sqlite3_column_count(statement);
                //NSLog(@"columnCount:%d",columnCount);
                unsigned char* cname = sqlite3_column_text(statement, 1);
                unsigned char* ctype = sqlite3_column_text(statement, 2);
                NSString* colName = [NSString stringWithUTF8String:cname];
                NSString* colType = [NSString stringWithUTF8String:ctype];
                [allColumnType setObject:colType forKey:colName];
                //do something with colName because it contains the column's name
            }
        }
        
        NSArray* allColumnName = [allColumnType allKeys];
        //将增加的字段分离出来
        NSArray* allPropertyNames = [self.propertyDict allKeys];
        
        NSMutableArray* addedPropertys = [NSMutableArray arrayWithCapacity:10];
        [allPropertyNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![allColumnName containsObject:obj]) {
                [addedPropertys addObject:obj];
            }
        }];
        // ALTER TABLE OLD_COMPANY ADD COLUMN SEX char(1);
        

        [addedPropertys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* name = obj;
            NSString* type = [self.propertyDict objectForKey:name];
            NSString* colType = @"";
            if ([type rangeOfString:@"NSString"].length > 0) {
                colType = @"TEXT";
            }else if ([type rangeOfString:@"NSNumber"].length > 0){
                colType = @"NUMERIC";
            }
            NSMutableString* alterSql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD ",[self.class tableName]];
            
            [alterSql appendFormat:@"%@ %@",name,colType];
            NSLog(@"警报：alterSql:%@",alterSql);
            if (sqlite3_exec(JSONDataModelDatabase, [alterSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                sqlite3_close(JSONDataModelDatabase);
                NSLog(@"数据库增加字段失败!");
            }
            
        }];

        
        //sqlite3_close(JSONDataModelDatabase);
        
        
        [tableNamesCheckedDict setObject:@"1" forKey:[self.class tableName]];
    }
}

-(void)addToBase{
    NSMutableString* insertColSql = [NSMutableString stringWithFormat:@"INSERT INTO %@(",[self.class tableName]];
    NSMutableString* insertValSql = [NSMutableString stringWithFormat:@"values("];
    __block BOOL first = YES;
    [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* colType = obj;
        id value = [self valueForKey:key];
        
        NSString* valueStr = @"";
        if ([colType rangeOfString:@"NSString"].length > 0) {
            valueStr = [NSString stringWithFormat:@"'%@'",value];
        }else{
            valueStr = [NSString stringWithFormat:@"%@",value];
        }
        
        if (value != nil) {
            if (first) {
                [insertColSql appendFormat:@"%@",key];
                [insertValSql appendFormat:@"%@",valueStr];
            }else{
                [insertColSql appendFormat:@",%@",key];
                [insertValSql appendFormat:@",%@",valueStr];
            }
            first = NO;
            
        }
        
    }];
    [insertColSql appendFormat:@")"];
    [insertValSql appendFormat:@")"];
    NSString* insertSql = [NSString stringWithFormat:@"%@ %@",insertColSql,insertValSql];
    NSLog(@"insertSql:%@",insertSql);
    char *err;
    if (sqlite3_exec(JSONDataModelDatabase, [insertSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(JSONDataModelDatabase);
        NSLog(@"数据库插入 数据失败! :%@",insertSql);
    }
}


+(NSArray*)selectAll{
    
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:50];
    
    NSString* selectSql = [NSString stringWithFormat:@"SELECT * FROM %@",[self tableName]];
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(JSONDataModelDatabase, [selectSql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement with message:get testValue.");
        return NO;
    }else {
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
        while (sqlite3_step(statement) == SQLITE_ROW) {
            JSONDataModel* model = [[self alloc] init];
            int colCount = sqlite3_column_int(statement,0);
            for (int i = 0; i < colCount; i++) {
                char* ccolName = (char*)sqlite3_column_name(statement, i);
                char* cstrText   = (char*)sqlite3_column_text(statement, i);
                int colType = sqlite3_column_type(statement, i);
                
                if (cstrText != nil) {
                    NSString* colName = [NSString stringWithUTF8String:ccolName];
                    id colValue = nil;
                    if (SQLITE_TEXT == colType) {
                        colValue = [NSString stringWithUTF8String:cstrText];
                    }else{
                        //数字
                        NSString* strValue = [NSString stringWithUTF8String:cstrText];
                        if ([strValue rangeOfString:@"."].length > 0) {
                            //浮点数
                            colValue = [NSNumber numberWithFloat:[strValue floatValue]];
                        }else{
                            if ([strValue longLongValue] > 0x0ffffff0) {
                                colValue = [NSNumber numberWithLongLong:[strValue longLongValue]];
                            }else{
                                colValue = [NSNumber numberWithInt:[strValue intValue]];
                            }
                        }
                    }
                    
                    
                    [model setValue:colValue forKey:colName];
                    //NSLog(@"colName:%@  colValue:%@",colName,colValue);
                }
                
            }
            [result addObject:model];
            
            
        }
    }
    
    
    return result;
}
+(NSArray*)selectWhere:(NSString*)where Order:(NSString*)order{
    return nil;
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
    NSMutableString* desc = [NSMutableString stringWithFormat:@"%@: [",[self.class tableName]];
    [desc appendFormat:@"primaryKey:%d \r",self.primaryKey];
    [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* colType = obj;
        id value = [self valueForKey:key];
        [desc appendFormat:@"%@<%@> = %@  \r",key,colType,value];
    }];
    [desc appendString:@"]"];
    return desc;
}

@end