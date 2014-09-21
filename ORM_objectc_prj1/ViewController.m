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
    
    [model addToBase];
    
    NSArray* result =[TestModel selectAll];
    NSLog(@"result:%@",result);
    
    //嫦娥
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
