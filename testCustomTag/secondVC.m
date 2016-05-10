//
//  secondVC.m
//  testCustomTag
//
//  Created by 王迎博 on 16/5/9.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "secondVC.h"

@interface secondVC ()
@property (nonatomic, strong) UITextField *textField;
@end

@implementation secondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加控件
    [self setUI];
    
}


/**
 *  添加控件
 */
- (void)setUI
{
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 200, 200, 40)];
    textField.placeholder = @"输入标签名字";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textField];
    self.textField = textField;
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 280, 50, 40 )];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}


/**
 *  懒加载
 */
- (NSMutableArray *)dataMutArr
{
    if (!_dataMutArr) {
        _dataMutArr = [NSMutableArray array];
    }
    return _dataMutArr;
}

- (NSMutableArray *)handAddTagIndexArr
{
    if (!_handAddTagIndexArr) {
        _handAddTagIndexArr = [NSMutableArray array];
    }
    return _handAddTagIndexArr;
}

/**
 *  返回上级页面
 */
- (void)goBack
{
    [self.textField resignFirstResponder];
    
    if (self.textField.text.length > 0)
    {
        [self.dataMutArr addObject:self.textField.text];
        NSInteger indexOfLastAddTagInDataMutArr = 0;
        if (self.dataMutArr.count > 0) {
            indexOfLastAddTagInDataMutArr = self.dataMutArr.count - 1;
        }
        NSString *indexStr = [NSString stringWithFormat:@"%ld",(long)indexOfLastAddTagInDataMutArr];
        [self.handAddTagIndexArr addObject:indexStr];
        self.block(self.dataMutArr,self.handAddTagIndexArr);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}



@end
