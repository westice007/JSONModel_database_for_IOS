//
//  TestModel.h
//  ORM_objectc_prj1
//
//  Created by giganotebook10.9 on 14-9-20.
//  Copyright (c) 2014年 giganotebook10.9. All rights reserved.
//

#import "JSONDataModel.h"

@interface TestModel : JSONDataModel


@property(nonatomic,assign)NSString* userName;
@property(nonatomic,assign)NSNumber* userAge;

@property(nonatomic,assign)NSString* userSchool;

@property(nonatomic,assign)NSNumber* userMoney;
@property(nonatomic,assign)NSNumber* userBooks;
@property(nonatomic,assign)NSString* userContry;

@end
