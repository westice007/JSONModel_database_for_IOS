//
//  TestModel.h
//  ORM_objectc_prj1
//
//  Created by giganotebook10.9 on 14-9-20.
//  Copyright (c) 2014年 giganotebook10.9. All rights reserved.
//

#import "JSONDataModel.h"

@interface TestModel : JSONDataModel


@property(nonatomic,retain)NSString* userName;
@property(nonatomic,retain)NSNumber* userAge;

@property(nonatomic,retain)NSString* userSchool;

@property(nonatomic,retain)NSNumber* userMoney;
@property(nonatomic,retain)NSNumber* userBooks;
@property(nonatomic,retain)NSString* userContry;

@property(nonatomic,retain)NSString<IgnoreProper>* testProp;

@end
