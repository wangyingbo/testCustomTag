//
//  secondVC.h
//  testCustomTag
//
//  Created by 王迎博 on 16/5/9.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^secondVCBlock)(NSArray *arrayData);

@interface secondVC : UIViewController

@property (nonatomic, strong) NSMutableArray *dataMutArr;

@property (nonatomic, copy) secondVCBlock block;

@end
