//
//  ViewController.m
//  testCustomTag
//
//  Created by 王迎博 on 16/4/28.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "TagView.h"



typedef NS_ENUM(BOOL,TagButtontype){
    Selected,
    NotSelected,
};

@interface TagButton : UIButton
{
}
@property (nonatomic, assign) TagButtontype tagButtonType;
@property (nonatomic, assign) CGFloat buttonW;
@property (nonatomic, assign) CGFloat tagInt;

- (instancetype)initWithTitle:(NSString *)title font:(UIFont *)font tagButtonType:(TagButtontype)tagButtonType frame:(CGRect)frame;

@end

@implementation TagButton

- (instancetype)initWithTitle:(NSString *)title font:(UIFont *)font tagButtonType:(TagButtontype)tagButtonType frame:(CGRect)frame{
    if (self = [super init]) {
        self.layer.cornerRadius = 5;
        
        //边框以及边框颜色
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = font;
        self.tagButtonType = tagButtonType;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        frame.size.width = [self getLabelWidthWithText:title stringFont:font allowHeight:30] + 40;
        self.buttonW = frame.size.width;
        self.frame = frame;
        
    }
    return self;
}

- (void)setTagButtonFrame:(CGRect)tagButtonFrame{
}

- (void)setTagButtonType:(TagButtontype)tagButtonType{
    _tagButtonType = tagButtonType;
    /**
     *  设置两种type的样式
     */
    if (tagButtonType == Selected) {
        self.backgroundColor = [UIColor cyanColor];
    }else if(tagButtonType == NotSelected){
        self.backgroundColor = [UIColor grayColor];
    }
}

/**
 *  根据label的内容自动算高度
 *
 *  @param text label的内容
 *
 *  @return label的高度
 */
- (CGFloat)getLabelWidthWithText:(NSString *)text stringFont:(UIFont *)font allowHeight:(CGFloat)height{
    CGFloat width;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(2000, height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    width = rect.size.width;
    return width;
}
@end


//*************************************************************************

#define TagButtonSpaceX 10 //两个tag之间水平方向间距
#define TagButtonSpaceY 10 //两个tag之间竖直方向间距
#define LeftToView      10 //距离左边的间距
#define RightToView     10 //距离右边的间距
#define TopToView       50 //距离顶部的间距
#define TagButtonSpaceBetweenSeletedAndNotSeleted 50 //选中和未选中tag之间的间距

#define SelectedButtonTag    1000
#define NotSelectedButtonTag 2000
#define isOrNotRepeatAdd 0  //是否支持同一个标签重复点击添加,0表示不能重复添加，1表示可以重复添加

@interface TagView()
{
    CGFloat _notSelectedMaxX;
    CGFloat _haveSelectedMaxX;
    
    CGFloat _getLastButtonFirstY;
    CGFloat _getLastButtonSecondY;
    BOOL _isNotFirstReload;
}


@end

@implementation TagView

@synthesize haveSelected = _haveSelected;

- (void)setHaveSelected:(NSMutableArray<NSString *> *)haveSelected{
    _haveSelected = haveSelected;
}

- (NSMutableArray *)haveSelected{
    if (_haveSelected == nil) {
        _haveSelected = [NSMutableArray array];
    }
    return _haveSelected;
}

- (NSMutableArray *)notSelected{
    if (_notSelected == nil) {
        _notSelected = [NSMutableArray array];
    }
    return _notSelected;
}

- (NSMutableArray *)selectedButtonBackArr
{
    if (!_selectedButtonBackArr) {
        _selectedButtonBackArr = [NSMutableArray array];
    }
    return _selectedButtonBackArr;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (CGFloat)tagViewButtonHeight{
    return _tagViewButtonHeight ? _tagViewButtonHeight:30;
}

- (NSInteger)tagViewButtonFont{
    return _tagViewButtonFont ? _tagViewButtonFont:13;
}



- (void)drawRect:(CGRect)rect
{
    for (UIButton *button in self.subviews)
    {
        [button removeFromSuperview];
    }
    
    
    NSInteger beginX = LeftToView;
    NSInteger beginY = TopToView;
    for (int i = 0; i< self.haveSelected.count; i++)
    {  //已经选择的标签
        TagButton *button = [[TagButton alloc] initWithTitle:self.haveSelected[i] font:[UIFont systemFontOfSize:self.tagViewButtonFont] tagButtonType:Selected frame:CGRectMake(beginX, beginY, 0, self.tagViewButtonHeight)];
        [button addTarget:self action:@selector(selectedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = SelectedButtonTag+i;
        
        if (CGRectGetMaxX(button.frame) + TagButtonSpaceX > (rect.size.width - RightToView)) {
            beginX = LeftToView;
            beginY += CGRectGetHeight(button.frame)+TagButtonSpaceY;
            CGRect rect = button.frame;
            rect.origin.x = beginX;
            rect.origin.y = beginY;
            button.frame = rect;
        }
        beginX = TagButtonSpaceX + CGRectGetMaxX(button.frame);
        
        //记录最后一个button的末尾X值
        if (i == self.haveSelected.count - 1)
        {
            _haveSelectedMaxX = beginX - TagButtonSpaceX;
            
            //决定是否要删除一行
            if (!_isNotFirstReload)
            {
                _getLastButtonFirstY = CGRectGetMaxY(button.frame);
            }else
            {
                _getLastButtonSecondY = CGRectGetMaxY(button.frame);
                if (_getLastButtonSecondY == _getLastButtonFirstY)
                {
                    //删除前和删除后Y值不变
                }else
                {
                    //删除后Y值改变
                    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.haveSelected,@"haveSelected",self.selectedButtonBackArr,@"haveSelectedSelectedButtonBackArr",nil];
                    //创建通知 第一步
                    NSNotification *notification =[NSNotification notificationWithName:@"haveSelected" object:self userInfo:dict];
                    //通过通知中心发送通知 第二步
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                    _getLastButtonFirstY = _getLastButtonSecondY;
                }
            }
        }
        
        [self addSubview:button];
    }
    
    
    
    beginX = LeftToView;
    beginY += self.tagViewButtonHeight + TagButtonSpaceBetweenSeletedAndNotSeleted;
    for (int i = 0; i< self.notSelected.count; i++)
    {  //没有选择的标签
        TagButton *button = [[TagButton alloc] initWithTitle:self.notSelected[i] font:[UIFont systemFontOfSize:self.tagViewButtonFont] tagButtonType:NotSelected frame:CGRectMake(beginX, beginY, 0, self.tagViewButtonHeight)];
        button.tag = NotSelectedButtonTag + i;
        [button addTarget:self action:@selector(notSelectedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (CGRectGetMaxX(button.frame) + TagButtonSpaceX > (rect.size.width - RightToView))
        {
            beginX = LeftToView;
            beginY += CGRectGetHeight(button.frame)+TagButtonSpaceY;
            CGRect rect = button.frame;
            rect.origin.x = beginX;
            rect.origin.y = beginY;
            button.frame = rect;
        }
        beginX = TagButtonSpaceX + CGRectGetMaxX(button.frame);
        
        //记录最后一个button的末尾X值
        if (i == self.notSelected.count - 1)
        {
            _notSelectedMaxX = beginX;
        }
    
        
        //给未选中button里的选中的button加背景色
        for (NSString *string in self.selectedButtonBackArr) {
            NSInteger index = [string integerValue];
            if (i == index) {
                button.backgroundColor = [UIColor greenColor];
                
                //是否支持同一个标签重复点击添加
                if (isOrNotRepeatAdd == 0) {
                    button.enabled = NO;
                }
            }
        }
        
        
        [self addSubview:button];
    }
}


- (void)selectedButtonClicked:(TagButton *)button{
    NSInteger index = button.tag - SelectedButtonTag;
    
    //[self.notSelected addObject:self.haveSelected[index]];
    [self.haveSelected removeObjectAtIndex:index];
    _isNotFirstReload = YES;
    [self.selectedButtonBackArr removeObjectAtIndex:index];
    [self setNeedsDisplay];
    
}



- (void)notSelectedButtonClicked:(TagButton *)button{
    NSInteger index = button.tag - NotSelectedButtonTag;
    [self.haveSelected insertObject:self.notSelected[index] atIndex:self.haveSelected.count];
    [self.selectedButtonBackArr addObject:[NSString stringWithFormat:@"%ld",(long)index]];

    //[self.notSelected removeObjectAtIndex:index];
    [self setNeedsDisplay];
    

    //NSLog(@"_haveSelectedMaxX:%f",_haveSelectedMaxX);
    //换行的时候发送通知
    if (_haveSelectedMaxX + TagButtonSpaceX + button.buttonW > (self.frame.size.width - RightToView))
    {
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.haveSelected,@"notSelected",self.selectedButtonBackArr,@"selectedButtonBackArr",nil];
        //创建通知 第一步
        NSNotification *notification =[NSNotification notificationWithName:@"notSelected" object:self userInfo:dict];
        //通过通知中心发送通知 第二步
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
}




@end
