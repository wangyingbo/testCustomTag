//
//  ViewController.m
//  testCustomTag
//
//  Created by 王迎博 on 16/4/28.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^customTagBlock)(NSArray *haveSelected,NSArray *selectedBackArr,NSArray *handAddArr);

@interface YBCustomTagView : UIView
/**
 *  tag的高度
 */
@property(nonatomic, assign) CGFloat tagViewButtonHeight;
/**
 *  tag的字号
 */
@property(nonatomic, assign) NSInteger tagViewButtonFont;
/**
 *  已经选择的tag的名字
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *haveSelected;
/**
 *  还未选中的tag的名字
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *notSelected;
/**
 *  选中的button的背景色
 */
@property (nonatomic, strong) NSMutableArray *selectedButtonBackArr;
/**
 *  block
 */
@property (nonatomic, copy) customTagBlock block;
/**
 *  手动添加的tag的位置
 */
@property (nonatomic, strong) NSArray *handAddTagIndexArr;

@end