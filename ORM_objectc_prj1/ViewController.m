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
    [model setValue:@1234567890 forKey:@"userAge"];
    model.userMoney = @98.4;
    model.userName = @"爸爸回来了去哪儿了？";
    
    //NSLog(@"model:%@",model);
    
    //[model addOneToBase];
    
    NSArray* result =[TestModel selectAllByOrder:@"ORDER BY userMoney ASC"];
    /*
    [result enumerateObjectsUsingBlock:^(TestModel* obj, NSUInteger idx, BOOL *stop) {
        obj.userBooks = [NSNumber numberWithInt:666];
        [obj updateOneToBase];
    }];
    result =[TestModel selectAll];
    */
    NSLog(@"result:%@",result);
    
    //NSArray* result2 = [TestModel selectWhere:@"WHERE userAge = 18" Order:nil];
    //NSLog(@"result2:%@",result2);
     
    
    TestModel* model2 = [[TestModel alloc] init];
    model2.userAge = @89;
    model2.userName = @"hahahah呵呵好";
    NSMutableArray* houses = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 4; i++) {
        TestModel* tempModel = [TestModel model];
        tempModel.userName = @"天天向上，";
        [houses addObject:tempModel];
    }
    model2.houseList = houses;
    
    NSLog(@"model2:%@",[model2 modelToDict]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
