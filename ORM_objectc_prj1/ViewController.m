//
//  ViewController.m
//  ORM_objectc_prj1
//
//  Created by giganotebook10.9 on 14-9-20.
//  Copyright (c) 2014年 giganotebook10.9. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    TestModel* model = [[TestModel alloc] init];
    [model setValue:@123456789012345 forKey:@"userAge"];
    model.userMoney = @45.3498;
    model.userName = @"爸爸回来了";
    
    //NSLog(@"model:%@",model);
    
    //[model addOneToBase];
    
    NSArray* result =[TestModel selectAll];
    [result enumerateObjectsUsingBlock:^(TestModel* obj, NSUInteger idx, BOOL *stop) {
        obj.userBooks = [NSNumber numberWithInt:555];
        [obj updateOneToBase];
    }];
    result =[TestModel selectAll];
    NSLog(@"result:%@",result);
    
    //NSArray* result2 = [TestModel selectWhere:@"WHERE userAge = 18" Order:nil];
    //NSLog(@"result2:%@",result2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
