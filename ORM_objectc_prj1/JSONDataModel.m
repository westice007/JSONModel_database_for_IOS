//
//  JSONDataModel.m
//  ORM_objectc_prj1
//
//  Created by giganotebook10.9 on 14-9-20.
//  Copyright (c) 2014年 giganotebook10.9. All rights reserved.
//

#import "JSONDataModel.h"


@implementation BlockClass



@end


@implementation JSONDataModel{
    
}

static sqlite3 *JSONDataModelDatabase = nil;
static NSMutableDictionary* tableNamesCheckedDict = nil;

#define USE_FMDB YES

static FMDatabaseQueue* fmDBShareQueuePtr = nil;

-(id)init{
    self = [super init];
    
    if (USE_FMDB) {
        [[self class] shareFBDBQueue];
    }else{
        if (JSONDataModelDatabase == nil) {
            [JSONDataModel initDataBase];
        }
    }
    
    //[self createOrUpdateTable];
    
    return self;
}

+(NSString*)tableName{
    return NSStringFromClass([self class]);
}

+(NSString*)filterChars:(NSString*)srcStr{
    srcStr = [srcStr stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
    //srcStr = [srcStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    return srcStr;
}

/*
static int insertOnecallback(void *para, int intn_column, char **column_value, char **azColName){
    int i;
    char* columnName;
    char* columnValueString;
    JSONDataModel* model = (__bridge JSONDataModel*)para;
    for(i=0; i<intn_column; i++){
        columnName = azColName[i];
        if (strcmp(columnName, "primaryKey")==0){
            columnValueString = column_value[i];
            NSString* valueString = [NSString stringWithUTF8String:columnValueString];
            
            model.primaryKey = [valueString intValue];
            model.insertBlock.voidintBlock(model.primaryKey);
            break;
        }
    }
    
    return 0;
}
*/


+(JSONDataModel*)selectByPrimaryKey:(int)pKey{
    NSString* whereSql = [NSString stringWithFormat:@"WHERE primaryKey=%d",pKey];
    NSMutableArray* result = [self selectWhere:whereSql];
    
    JSONDataModel* model = [result firstObject];
    if (model == nil) {
        model = [self model];
    }
    return model;
}

+(NSArray*)selectAll{
    
    NSString* selectSql = [NSString stringWithFormat:@"SELECT * FROM %@",[self tableName]];
    
    NSMutableArray* result = [self selectWithSql:selectSql];
    
    return result;
}

+(NSArray*)selectAllByOrder:(NSString*)order{
    return [self selectWhere:nil Order:order RowLimit:0];
}
+(NSArray*)selectAllByOrder:(NSString*)order RowLimit:(int)rows{
    return [self selectWhere:nil Order:order RowLimit:rows];
}

+(NSArray*)selectWhere:(NSString*)where{
    return [self.class selectWhere:where Order:nil RowLimit:0];
}
+(NSArray*)selectWhere:(NSString*)where Order:(NSString*)order RowLimit:(int)rows{
    NSMutableArray* result = [self selectWhere:where IgnoreColumns:nil Order:order RowLimit:rows];
    return result;
}

+(NSArray*)selectWhere:(NSString*)where IgnoreColumns:(NSArray*)columns Order:(NSString*)order RowLimit:(int)rows{
    if (where == nil) {
        where = @"";
    }
    where = [JSONDataModel filterChars:where];
    if (order == nil) {
        order = @"";
    }
    NSString* limit = @"";
    if (rows != 0) {
        limit = [NSString stringWithFormat:@"LIMIT %d",rows];
    }
    
    //移除不需要查找的字段
    NSString* colNames = @"*";
    
    if ([columns count] > 0) {
        NSMutableArray* allKeys = [[self model].propertyDict allKeys];
        NSMutableArray* propNames = [NSMutableArray arrayWithArray:allKeys];
        [propNames addObject:@"primaryKey"];
        [propNames removeObjectsInArray:columns];
        colNames = [propNames componentsJoinedByString:@","];
    }
    
    
    
    
    NSString* selectSql = [NSString stringWithFormat:@"SELECT %@ FROM %@ %@ %@ %@",colNames,[self tableName],where,order,limit];
    NSMutableArray* result = [self selectWithSql:selectSql];
    return result;
}

-(void)updateOneToBase{
    //NSMutableString
    //"INSERT OR REPLACE INTO PERSIONINFO(NAME,AGE,SEX,WEIGHT,ADDRESS)""VALUES(?,?,?,?,?);";
    // UPDATE tablename SET name = 'xxx' ,age = 34 WHERE
    if (self.primaryKey > 0) {
        [self.class updateWhere:[NSString stringWithFormat:@"WHERE primaryKey = %d",self.primaryKey] NewData:self];
    }else{
        //NSLog(@"primary key 那里去了? :%@",[self.class tableName]);
        [self addOneToBase];
    }
    
}

-(void)updateOneToBaseWithKey:(NSString*)colName Value:(id)value{
    
}

-(void)deleteOneFromBase{
    if (self.primaryKey > 0) {
        [self.class deleteWhere:[NSString stringWithFormat:@"WHERE primaryKey = %d",self.primaryKey]];
    }else{
        NSLog(@"primary key 那里去了? :%@",[self.class tableName]);
    }
}

+(NSString*)dataBaseFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
#if TARGET_IPHONE_SIMULATOR
    
    //NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    //NSString *desktopDirectory = [paths2 objectAtIndex:0];
    //NSLog(@"desktopDirectory:%@",desktopDirectory);
    
    NSString*bundel=[[NSBundle mainBundle] resourcePath];
    NSString*deskTopLocation=[[bundel substringToIndex:[bundel rangeOfString:@"Library"].location] stringByAppendingFormat:@"Desktop"];
    documentsDirectory = deskTopLocation;
    
#endif
    
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString* fileName = [NSString stringWithFormat:@"%@_JSONDataModelDatabase.sqlite",identifier];
    NSString* basePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    //NSLog(@"JSONDataModelDatabase basePath:%@",basePath);
    return basePath;
}



+(FMDatabaseQueue*)shareFBDBQueue{
    if (fmDBShareQueuePtr == nil) {
        NSString* basePath = [self dataBaseFilePath];
        fmDBShareQueuePtr = [FMDatabaseQueue databaseQueueWithPath:basePath];
        tableNamesCheckedDict = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return fmDBShareQueuePtr;
}


+(void)initDataBase{

    NSString* basePath = [self dataBaseFilePath];
    NSLog(@"JSONDataModelDatabase basePath:%@",basePath);
    if (sqlite3_open([basePath UTF8String], &JSONDataModelDatabase) != SQLITE_OK) {
        sqlite3_close(JSONDataModelDatabase);
        
    }
    
    tableNamesCheckedDict = [NSMutableDictionary dictionaryWithCapacity:20];
    
}




+(void)updateWhere:(NSString*)where NewData:(JSONDataModel*)newModel{
    [self createOrUpdateTable];
    if (USE_FMDB) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
        [[[self class] shareFBDBQueue] inDatabase:^(FMDatabase *db) {
            //[db open];
            /*
            NSMutableString* updateSql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[self.class tableName]];
            __block BOOL first = YES;
            
            [newModel.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString* colType = obj;
                id value = [newModel valueForKey:key];
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    NSString* valueStr = nil;
                    if ([colType rangeOfString:@"NSString"].length > 0) {
                        valueStr = [NSString stringWithFormat:@"\"%@\"",value];
                        valueStr = [JSONDataModel filterChars:valueStr];
                    }
                    if ([colType rangeOfString:@"NSNumber"].length > 0) {
                        valueStr = [NSString stringWithFormat:@"%@",value];
                    }
                    
                    if (valueStr != nil && value != nil) {
                        if (first) {
                            [updateSql appendFormat:@"%@ = %@",key,valueStr];
                        }else{
                            [updateSql appendFormat:@",%@ = %@",key,valueStr];
                        }
                        first = NO;
                        
                    }
                }
                
            }];
            [updateSql appendFormat:@" %@",where];
            */
            NSMutableArray* colNameArray = [NSMutableArray arrayWithCapacity:10];
            NSMutableDictionary* colValueDict = [NSMutableDictionary dictionaryWithCapacity:10];
            [newModel.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString* colType = obj;
                id value = [newModel valueForKey:key];
                if ([colType rangeOfString:@"NSString"].length > 0) {
                    
                    //value = [NSString stringWithFormat:@"%@",value];
                    //value = [JSONDataModel filterChars:value];
                }
                
                if (value != nil) {
                    [colNameArray addObject:[NSString stringWithFormat:@"%@=:%@",key,key]];
                    [colValueDict setObject:value forKey:key];
                }
                
            }];
            NSString* colNames = [colNameArray componentsJoinedByString:@","];
            NSString* updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ %@",[self.class tableName],colNames,where];
            
            BOOL updateSuccess = [db executeUpdate:updateSql withParameterDictionary:colValueDict];
            
            if (!updateSuccess) {
                NSLog(@"更新失败：%@",updateSql);
            }
            
            //[db close];
            dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
    }else{
        NSLock* lock = [[NSLock alloc] init];
        [lock lock];
        if (JSONDataModelDatabase == nil) {
            [JSONDataModel initDataBase];
        }
        
        NSMutableString* updateSql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[self.class tableName]];
        __block BOOL first = YES;
        
        [newModel.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString* colType = obj;
            id value = [newModel valueForKey:key];
            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                NSString* valueStr = nil;
                if ([colType rangeOfString:@"NSString"].length > 0) {
                    valueStr = [NSString stringWithFormat:@"\"%@\"",value];
                    valueStr = [JSONDataModel filterChars:valueStr];
                }
                if ([colType rangeOfString:@"NSNumber"].length > 0) {
                    valueStr = [NSString stringWithFormat:@"%@",value];
                }
                
                if (valueStr != nil && value != nil) {
                    if (first) {
                        [updateSql appendFormat:@"%@ = %@",key,valueStr];
                    }else{
                        [updateSql appendFormat:@",%@ = %@",key,valueStr];
                    }
                    first = NO;
                    
                }
            }
            
        }];
        [updateSql appendFormat:@" %@",where];
        
        //NSLog(@"updateSql:%@",updateSql);
        char *err;
        if (sqlite3_exec(JSONDataModelDatabase, [updateSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            sqlite3_close(JSONDataModelDatabase);
            NSLog(@"数据库更新 数据失败! :%@",updateSql);
        }
        [lock unlock];
    
    }
    

}

+(void)replaceWhere:(NSString*)where NewData:(JSONDataModel*)newModel{

    /*
    if (JSONDataModelDatabase == nil) {
        [JSONDataModel initDataBase];
    }
    NSMutableString* updateSql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[self.class tableName]];
    __block BOOL first = YES;
    
    [newModel.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* colType = obj;
        id value = [newModel valueForKey:key];
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            NSString* valueStr = nil;
            if ([colType rangeOfString:@"NSString"].length > 0) {
                valueStr = [NSString stringWithFormat:@"'%@'",value];
            }
            if ([colType rangeOfString:@"NSNumber"].length > 0) {
                valueStr = [NSString stringWithFormat:@"%@",value];
            }
            
            if (valueStr != nil && value != nil) {
                if (first) {
                    [updateSql appendFormat:@"%@ = %@",key,valueStr];
                }else{
                    [updateSql appendFormat:@",%@ = %@",key,valueStr];
                }
                first = NO;
                
            }
        }
        
    }];
    [updateSql appendFormat:@" %@",where];
    
    NSLog(@"updateSql:%@",updateSql);
    char *err;
    if (sqlite3_exec(JSONDataModelDatabase, [updateSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(JSONDataModelDatabase);
        NSLog(@"数据库更新 数据失败! :%@",updateSql);
    }
     */
}



+(void)deleteWhere:(NSString*)where{
    
    [self createOrUpdateTable];
    
    
    
    if (USE_FMDB) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
        [[[self class] shareFBDBQueue] inDatabase:^(FMDatabase *db) {
            //[db open];
            NSString* nwhere = [JSONDataModel filterChars:where];
            if ([nwhere rangeOfString:@"WHERE"].length > 0) {
                NSMutableString* delSql = [NSMutableString stringWithFormat:@"DELETE FROM %@ %@",[self.class tableName],nwhere];
                //NSLog(@"delSql:%@",delSql);
                
                if (![db executeUpdate:delSql]) {
                    NSLog(@"删除失败：%@",delSql);
                }
                
                
            }else{
                NSLog(@"删除%@ 时没写 WHERE",[self.class tableName]);
            }
            
            
            //[db close];
            dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
    }else{
    
        NSLock* lock = [[NSLock alloc] init];
        [lock lock];
        if (JSONDataModelDatabase == nil) {
            [JSONDataModel initDataBase];
        }
        where = [JSONDataModel filterChars:where];
        if ([where rangeOfString:@"WHERE"].length > 0) {
            NSMutableString* delSql = [NSMutableString stringWithFormat:@"DELETE FROM %@ %@",[self.class tableName],where];
            NSLog(@"delSql:%@",delSql);
            char *err;
            if (sqlite3_exec(JSONDataModelDatabase, [delSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                sqlite3_close(JSONDataModelDatabase);
                NSLog(@"数据库更新 数据失败! :%@",delSql);
            }
        }else{
            NSLog(@"删除%@ 时没写 WHERE",[self.class tableName]);
        }
        [lock unlock];
    }
    

}


+(int)countWhere:(NSString*)where{
    __block int resultCount = 0;
    if (USE_FMDB) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
        [[[self class] shareFBDBQueue] inDatabase:^(FMDatabase *db) {
            //[db open];
            NSString* countSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ %@",[self tableName],where];
            
            //查询sql
            FMResultSet* rs = [db executeQuery:countSql];
            while ([rs next]) {
                
                resultCount = [rs intForColumnIndex:0];
                
            }
            //[db close];
            dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
    }else{
    
        NSLock * lock = [[NSLock alloc] init];
        [lock lock];
        if (where == nil) {
            where = @"";
        }
        where = [JSONDataModel filterChars:where];
        if (JSONDataModelDatabase == nil) {
            [JSONDataModel initDataBase];
        }
        
        NSString* countSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ %@",[self tableName],where];
        
        sqlite3_stmt *statement = nil;
        if (sqlite3_prepare_v2(JSONDataModelDatabase, [countSql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get testValue.");
            return NO;
        }else {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int colCount = sqlite3_column_count(statement);
                for (int i = 0; i < colCount; i++) {
                    //char* ccolName = (char*)sqlite3_column_name(statement, i);
                    char* cstrText   = (char*)sqlite3_column_text(statement, i);
                    //int colType = sqlite3_column_type(statement, i);
                    
                    if (cstrText != nil) {
                        //NSString* colName = [NSString stringWithUTF8String:ccolName];
                        id colValue = [NSString stringWithUTF8String:cstrText];;
                        resultCount = [colValue intValue];
                        break;
                    }
                    
                }
                
                
            }
        }
        [lock unlock];
    }
    

    return resultCount;
}



+(NSArray*)selectWithSql:(NSString*)selectSql{
    
    [self createOrUpdateTable];
    
    __block NSMutableArray* result = [NSMutableArray arrayWithCapacity:50];
    //NSLock* lock = [[NSLock alloc] init]; [lock lock];
    if (USE_FMDB) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
        [[self shareFBDBQueue] inDatabase:^(FMDatabase *db) {
            //[db open];
            //查询sql
            FMResultSet* rs = [db executeQuery:selectSql];
            while ([rs next]) {
                
                JSONDataModel* model = [self model];
                model.primaryKey = [rs intForColumn:@"primaryKey"];
                [[model propertyDict] enumerateKeysAndObjectsUsingBlock:^(NSString* propName, NSString* propType, BOOL *stop) {
                    
                    id colValue = nil;
                    if (CONTAIN_STRING(propType,@"NSString")) {
                        NSString* strValue = [rs stringForColumn:propName];
                        colValue = strValue;
                    }else if(CONTAIN_STRING(propType,@"NSNumber")){
                        NSString* strValue = [rs stringForColumn:propName];
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
                    }else if(CONTAIN_STRING(propType,@"NSData") || CONTAIN_STRING(propType,@"NSMutableData")){
                        NSData* dataValue = [rs dataForColumn:propName];
                        colValue = dataValue;
                    }
                    
                    if (colValue != nil) {
                        [model setValue:colValue forKey:propName];
                    }
                    
                }];
                [result addObject:model];
            }
            [rs close];
            //[db close];
            dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
        }];
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
        
    }else{
        NSLock* lock = [[NSLock alloc] init];
        [lock lock];
        //NSLog(@"sql :%@",selectSql);
        if (JSONDataModelDatabase == nil) {
            [JSONDataModel initDataBase];
        }
        
        
        
        sqlite3_stmt *statement = nil;
        if (sqlite3_prepare_v2(JSONDataModelDatabase, [selectSql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get testValue.");
            return NO;
        }else {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
            while (sqlite3_step(statement) == SQLITE_ROW) {
                JSONDataModel* model = [[self alloc] init];
                int colCount = sqlite3_column_count(statement);
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
                        
                        if ([[[model propertyDict] allKeys] containsObject:colName] || [colName isEqualToString:@"primaryKey"]) {
                            [model setValue:colValue forKey:colName];
                        }
                        
                        //NSLog(@"colName:%@  colValue:%@",colName,colValue);
                    }
                    
                }
                [result addObject:model];
                
                
            }
        }
        [lock unlock];
        
    }
    
    //[lock unlock];
    
    return result;
}


-(void)addOneToBase{
    [[self class] createOrUpdateTable];
    
    if (USE_FMDB) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
        [[[self class] shareFBDBQueue] inDatabase:^(FMDatabase *db) {
            //[db open];
            /*
            NSMutableString* insertColSql = [NSMutableString stringWithFormat:@"INSERT INTO %@(",[self.class tableName]];
            NSMutableString* insertValSql = [NSMutableString stringWithFormat:@"values("];
            __block BOOL first = YES;
            [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString* colType = obj;
                id value = [self valueForKey:key];
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    NSString* valueStr = @"";
                    if ([colType rangeOfString:@"NSString"].length > 0) {
                        
                        valueStr = [NSString stringWithFormat:@"\"%@\"",value];
                        valueStr = [JSONDataModel filterChars:valueStr];
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
                }
            }];
            [insertColSql appendFormat:@")"];
            [insertValSql appendFormat:@")"];
            NSString* insertSql = [NSString stringWithFormat:@"%@ %@",insertColSql,insertValSql];
            
            BOOL insertSuccess = [db executeUpdate:insertSql];
             */
            NSMutableArray* colNameArray = [NSMutableArray arrayWithCapacity:10];
            NSMutableArray* colColonNameArray = [NSMutableArray arrayWithCapacity:10];
            NSMutableDictionary* colValueDict = [NSMutableDictionary dictionaryWithCapacity:10];
            [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString* colType = obj;
                id value = [self valueForKey:key];
                if ([colType rangeOfString:@"NSString"].length > 0) {
                    
                    //value = [NSString stringWithFormat:@"%@",value];
                    //value = [JSONDataModel filterChars:value];
                }
                
                if (value != nil) {
                    [colNameArray addObject:key];
                    [colColonNameArray addObject:[NSString stringWithFormat:@":%@",key]];
                    [colValueDict setObject:value forKey:key];
                }
                
            }];
            
            NSString* colColonNames = [colColonNameArray componentsJoinedByString:@","];
            NSString* colNames = [colNameArray componentsJoinedByString:@","];
            NSString* insertSql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)",[self.class tableName],colNames,colColonNames];
            
            BOOL insertSuccess = [db executeUpdate:insertSql withParameterDictionary:colValueDict];
            
            if (!insertSuccess) {
                NSLog(@"插入失败：%@",insertSql);
            }
            
            self.primaryKey = [db lastInsertRowId];
            
            //[db close];
            dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
         
    }else{
        
        NSLock* lock = [[NSLock alloc] init];
        [lock lock];
        NSMutableString* insertColSql = [NSMutableString stringWithFormat:@"INSERT INTO %@(",[self.class tableName]];
        NSMutableString* insertValSql = [NSMutableString stringWithFormat:@"values("];
        __block BOOL first = YES;
        [self.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString* colType = obj;
            id value = [self valueForKey:key];
            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                NSString* valueStr = @"";
                if ([colType rangeOfString:@"NSString"].length > 0) {
                    
                    valueStr = [NSString stringWithFormat:@"\"%@\"",value];
                    valueStr = [JSONDataModel filterChars:valueStr];
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
            }
        }];
        [insertColSql appendFormat:@")"];
        [insertValSql appendFormat:@")"];
        NSString* insertSql = [NSString stringWithFormat:@"%@ %@",insertColSql,insertValSql];
        //NSLog(@"insertSql:%@",insertSql);
        char *err;
        void* voidSelf = (__bridge void *)(self);
        if (sqlite3_exec(JSONDataModelDatabase, [insertSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            sqlite3_close(JSONDataModelDatabase);
            NSLog(@"数据库插入 数据失败! :%@",insertSql);
        }
        //查找主箭
        int rowId = sqlite3_last_insert_rowid(JSONDataModelDatabase);
        //NSLog(@"rowId:%d",rowId);
        self.primaryKey = rowId;
        
        [lock unlock];
    }
    

}


+(void)createOrUpdateTable{
    //检查表的结构，创建或者更新字段
    
    if (USE_FMDB) {
        
        NSString* checked = [tableNamesCheckedDict objectForKey:[self tableName]];
        if ([checked intValue] == 0){
            
            JSONDataModel* model = [self model];
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
            [[JSONDataModel shareFBDBQueue] inDatabase:^(FMDatabase *db) {
                //[db open];
                NSMutableString* sqlCreate = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (primaryKey INTEGER PRIMARY KEY AUTOINCREMENT,",[self tableName]];
                
                __block BOOL first = YES;
                
                [model.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    NSString* colType = nil;
                    if ([obj rangeOfString:@"NSString"].length > 0) {
                        colType = @"TEXT";
                    }else if ([obj rangeOfString:@"NSNumber"].length > 0){
                        colType = @"NUMERIC";
                    }else if (CONTAIN_STRING(obj,@"NSData") || CONTAIN_STRING(obj,@"NSMutableData")){
                        colType = @"BLOB";
                    }
                    if (colType != nil) {
                        if (first) {
                            [sqlCreate appendFormat:@"%@ %@",key,colType];
                        }else{
                            [sqlCreate appendFormat:@",%@ %@",key,colType];
                        }
                        first = NO;
                    }
                    
                }];
                [sqlCreate appendString:@")"];
                
                if (![db executeUpdate:sqlCreate]) {
                    NSLog(@"创建失败：%@",sqlCreate);
                }
                
                //查询表的结构
                NSString* pragmaSql = [NSString stringWithFormat:@"PRAGMA table_info ('%@')",[self tableName]];
                NSMutableDictionary* allColumnType = [NSMutableDictionary dictionaryWithCapacity:10];
                
                FMResultSet* rs = [db executeQuery:pragmaSql];
                while ([rs next]) {
                    
                    NSString* colName = [rs stringForColumnIndex:1];
                    NSString* colType = [rs stringForColumnIndex:2];
                    if (![colName isEqualToString:@"primaryKey"]) {
                        [allColumnType setObject:colType forKey:colName];
                    }
                    
                }
                [rs close];
                
                NSArray* allColumnName = [allColumnType allKeys];
                //将增加的字段分离出来
                NSArray* allPropertyNames = [model.propertyDict allKeys];
                
                NSMutableArray* addedPropertys = [NSMutableArray arrayWithCapacity:10];
                [allPropertyNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString* colTypeStr = [model.propertyDict objectForKey:obj];
                    NSString* colType = nil;
                    if ([colTypeStr rangeOfString:@"NSString"].length > 0) {
                        colType = @"TEXT";
                    }else if ([colTypeStr rangeOfString:@"NSNumber"].length > 0){
                        colType = @"NUMERIC";
                    }else if (CONTAIN_STRING(obj,@"NSData") || CONTAIN_STRING(obj,@"NSMutableData")){
                        colType = @"BLOB";
                    }
                    
                    if (colType != nil && ![allColumnName containsObject:obj]) {
                        [addedPropertys addObject:obj];
                    }
                }];
                
                [addedPropertys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString* name = obj;
                    NSString* type = [model.propertyDict objectForKey:name];
                    NSString* colType = @"";
                    if ([type rangeOfString:@"NSString"].length > 0) {
                        colType = @"TEXT";
                    }else if ([type rangeOfString:@"NSNumber"].length > 0){
                        colType = @"NUMERIC";
                    }else if (CONTAIN_STRING(obj,@"NSData") || CONTAIN_STRING(obj,@"NSMutableData")){
                        colType = @"BLOB";
                    }
                    NSMutableString* alterSql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD ",[self tableName]];
                    
                    [alterSql appendFormat:@"%@ %@",name,colType];
                    if (![db executeUpdate:alterSql]) {
                        NSLog(@"增加字段失败：%@",alterSql);
                    }
                    
                }];
                //[db close];
                dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
            
            [tableNamesCheckedDict setObject:@"1" forKey:[self tableName]];
        }
        
        
        
    }else{
        NSString* checked = [tableNamesCheckedDict objectForKey:[self tableName]];
        if ([checked intValue] == 0) {
            NSLock * lock = [[NSLock alloc] init];
            [lock lock];
            //NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS TestModel (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, address TEXT)";
            
            JSONDataModel* model = [self model];
            
            NSMutableString* sqlCreate = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (primaryKey INTEGER PRIMARY KEY AUTOINCREMENT,",[self tableName]];
            
            __block BOOL first = YES;
            
            [model.propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString* colType = nil;
                if ([obj rangeOfString:@"NSString"].length > 0) {
                    colType = @"TEXT";
                }else if ([obj rangeOfString:@"NSNumber"].length > 0){
                    colType = @"NUMERIC";
                }
                if (colType != nil) {
                    if (first) {
                        [sqlCreate appendFormat:@"%@ %@",key,colType];
                    }else{
                        [sqlCreate appendFormat:@",%@ %@",key,colType];
                    }
                    first = NO;
                }
                
            }];
            [sqlCreate appendString:@")"];
            NSLog(@"sqlCreate:%@",sqlCreate);
            
            char *err;
            if (sqlite3_exec(JSONDataModelDatabase, [sqlCreate UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                sqlite3_close(JSONDataModelDatabase);
                NSLog(@"数据库创建表失败!");
            }
            
            NSString* pragmaSql = [NSString stringWithFormat:@"PRAGMA table_info ('%@')",[self tableName]];
            NSMutableDictionary* allColumnType = [NSMutableDictionary dictionaryWithCapacity:10];
            sqlite3_stmt * statement;
            int rc = sqlite3_prepare_v2(JSONDataModelDatabase, [pragmaSql UTF8String], -1, &statement, NULL);
            
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
            NSArray* allPropertyNames = [model.propertyDict allKeys];
            
            NSMutableArray* addedPropertys = [NSMutableArray arrayWithCapacity:10];
            [allPropertyNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString* colTypeStr = [model.propertyDict objectForKey:obj];
                NSString* colType = nil;
                if ([colTypeStr rangeOfString:@"NSString"].length > 0) {
                    colType = @"TEXT";
                }else if ([colTypeStr rangeOfString:@"NSNumber"].length > 0){
                    colType = @"NUMERIC";
                }
                
                if (colType != nil && ![allColumnName containsObject:obj]) {
                    [addedPropertys addObject:obj];
                }
            }];
            // ALTER TABLE OLD_COMPANY ADD COLUMN SEX char(1);
            
            
            [addedPropertys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString* name = obj;
                NSString* type = [model.propertyDict objectForKey:name];
                NSString* colType = @"";
                if ([type rangeOfString:@"NSString"].length > 0) {
                    colType = @"TEXT";
                }else if ([type rangeOfString:@"NSNumber"].length > 0){
                    colType = @"NUMERIC";
                }
                NSMutableString* alterSql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD ",[self tableName]];
                
                [alterSql appendFormat:@"%@ %@",name,colType];
                NSLog(@"警报：alterSql:%@",alterSql);
                if (sqlite3_exec(JSONDataModelDatabase, [alterSql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                    sqlite3_close(JSONDataModelDatabase);
                    NSLog(@"数据库增加字段失败!");
                }
                
            }];
            
            
            //sqlite3_close(JSONDataModelDatabase);
            
            
            [tableNamesCheckedDict setObject:@"1" forKey:[self tableName]];
            
            [lock unlock];
        }
        
    }
    

}

+(void)createIndexForColumn:(NSString*)columnName{
    if (USE_FMDB) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
        [[[self class] shareFBDBQueue] inDatabase:^(FMDatabase *db) {
            
            NSMutableString* createSql = [NSMutableString stringWithFormat:@"CREATE INDEX %@_%@_INDEX on %@ (%@)",columnName,[self.class tableName],[self.class tableName],columnName];
            //NSLog(@"delSql:%@",delSql);
            
            if (![db executeUpdate:createSql]) {
                NSLog(@"创建索引失败：%@",createSql);
            }
            
            dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
    }
}



+(void)clearThisTable{
    if (USE_FMDB) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);  //创建信号量
        [[[self class] shareFBDBQueue] inDatabase:^(FMDatabase *db) {

            NSMutableString* clearSql = [NSMutableString stringWithFormat:@"DELETE FROM %@",[self.class tableName]];
            //NSLog(@"delSql:%@",delSql);
            
            if (![db executeUpdate:clearSql]) {
                NSLog(@"删除失败：%@",clearSql);
            }
            
            dispatch_semaphore_signal(sema);  //关键点，在此发送信号量
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  //关键点，在此等待信号量
    }
}


-(NSString*)description{
    NSMutableString* desc = [super description];
    
    return [NSString stringWithFormat:@"primaryKey:%d \r %@",self.primaryKey,desc];
}

@end
