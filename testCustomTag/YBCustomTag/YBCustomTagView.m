//
//  ViewController.m
//  testCustomTag
//
//  Created by 王迎博 on 16/4/28.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "YBCustomTagView.h"
#import "ImageTextButton.h"

#define MYCOLOR [UIColor colorWithRed:(36)/255.0 green:(183)/255.0 blue:(155)/255.0 alpha:1.0]
#define allowLabelH 30
#define labelSpaceW 50


typedef NS_ENUM(BOOL,TagButtontype){
    Selected,
    NotSelected,
};

@interface TagButton : ImageTextButton
{
    
}
@property (nonatomic, assign) TagButtontype tagButtonType;
@property (nonatomic, assign) CGFloat buttonW;
@property (nonatomic, assign) CGFloat tagInt;
@property (nonatomic, assign) BOOL isOrNotExtraAddButton;

- (instancetype)initWithTitle:(NSString *)title font:(UIFont *)font tagButtonType:(TagButtontype)tagButtonType frame:(CGRect)frame;

@end

@implementation TagButton

- (instancetype)initWithTitle:(NSString *)title font:(UIFont *)font tagButtonType:(TagButtontype)tagButtonType frame:(CGRect)frame{
    if (self = [super init]) {
        self.layer.cornerRadius = 5;
        
        //边框以及边框颜色
        //self.layer.borderWidth = 1.0;
        //self.layer.borderColor = [UIColor blackColor].CGColor;
        [self setTitleColor:MYCOLOR forState:UIControlStateNormal];
        
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = font;
        self.tagButtonType = tagButtonType;
        
        frame.size.width = [self getLabelWidthWithText:title stringFont:font allowHeight:allowLabelH] + labelSpaceW;
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
        self.backgroundColor = [UIColor whiteColor];
        //边框以及边框颜色
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = MYCOLOR.CGColor;
    }else if(tagButtonType == NotSelected){
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = MYCOLOR.CGColor;
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
#define TagButtonSpaceBetweenSeletedAndNotSeleted 80 //选中和未选中tag之间的间距
#define cutViewH 15

#define SelectedButtonTag    1000
#define NotSelectedButtonTag 2000
#define isOrNotRepeatAdd 0  //是否支持同一个标签重复点击添加,0表示不能重复添加，1表示可以重复添加

extern NSString *notSelected;
extern NSString *selected;
extern NSString *handAdd;

@interface YBCustomTagView()
{
    CGFloat _notSelectedMaxX;
    CGFloat _haveSelectedMaxX;
    
    //根据haveSelected数组的末尾button的Y值是否改变来判断是否需要换行
    CGFloat _getLastButtonFirstY;
    CGFloat _getLastButtonSecondY;
    BOOL _isNotFirstReload;
}


@end

@implementation YBCustomTagView

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
    
    if (self.haveSelected) {
        //添加“已增加标签”表头
        [self addHaveAddHeader];
    }
    
    NSInteger buttonTagInt = 0;
    for (int i = 0; i< self.haveSelected.count; i++)
    {  //已经选择的标签
        NSMutableArray *selectedKey = [NSMutableArray array];
        NSMutableArray *selectedValue = [NSMutableArray array];
        for (NSDictionary *dic in self.haveSelected) {
            NSString *keyStr = [[dic allKeys] firstObject];
            NSString *valueStr = [[dic allValues] firstObject];
            [selectedValue addObject:valueStr];
            [selectedKey addObject:keyStr];
        }
        
        TagButton *button = [[TagButton alloc] initWithTitle:selectedKey[i] font:[UIFont systemFontOfSize:self.tagViewButtonFont] tagButtonType:Selected frame:CGRectMake(beginX, beginY, 0, self.tagViewButtonHeight)];
        [button addTarget:self action:@selector(selectedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = SelectedButtonTag+i;
        
        //设置button的图片放在右边---先设置图片，再调用方法
        [button setImage:[UIImage imageNamed:@"delegate_tag"] forState:UIControlStateNormal];
        button.imgTextDistance = 15;
        [button setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft];
        
        //判断是从下面notSelected数组里添加的还是手动添加的
        if ([selectedValue[i] isEqualToString:notSelected])
        {
            button.isOrNotExtraAddButton = YES;
            button.tagInt = buttonTagInt;
            buttonTagInt ++;
        }
        
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
    
    //添加"推荐标签"表头
    [self addRecommendHeader:beginY];
    
    for (int i = 0; i< self.notSelected.count; i++)
    {  //没有选择的标签
        NSMutableArray *notSelectedKey = [NSMutableArray array];
        NSMutableArray *notSelectedValue = [NSMutableArray array];
        for (NSDictionary *dic in self.notSelected) {
            NSString *keyStr = [[dic allKeys] firstObject];
            NSString *valueStr = [[dic allValues] firstObject];
            [notSelectedValue addObject:valueStr];
            [notSelectedKey addObject:keyStr];
        }
        TagButton *button = [[TagButton alloc] initWithTitle:notSelectedKey[i] font:[UIFont systemFontOfSize:self.tagViewButtonFont] tagButtonType:NotSelected frame:CGRectMake(beginX, beginY, 0, self.tagViewButtonHeight)];
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
        for (NSString *string in self.selectedButtonBackArr)
        {
            NSInteger index = [string integerValue];
            if (i == index) {
                button.backgroundColor = MYCOLOR;
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //是否支持同一个标签重复点击添加
                if (isOrNotRepeatAdd == 0)
                {
                    button.enabled = NO;
                }
            }
        }
        
        
        [self addSubview:button];
    }
    
    
    //block传值
    self.block(self.haveSelected,self.selectedButtonBackArr);
}


/**
 *  添加“已增加标签”表头
 */
- (void)addHaveAddHeader
{
    CGFloat haveAddLabelH = 20;
    CGFloat haveAddLabelW = 100;
    UILabel *haveAddLabel = [[UILabel alloc]initWithFrame:CGRectMake(LeftToView, cutViewH, haveAddLabelW, haveAddLabelH)];
    haveAddLabel.text = @"已添加标签";
    haveAddLabel.font = [UIFont systemFontOfSize:14.0];
    haveAddLabel.textColor = [UIColor blackColor];
    haveAddLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:haveAddLabel];
}


/**
 *  添加"推荐标签"表头
 */
- (void)addRecommendHeader:(CGFloat)beginY
{
    //添加“推荐标签”
    CGFloat recommendLabelH = 20;
    CGFloat recommendLabelW = 100;
    CGFloat recommendLabelX = LeftToView;
    CGFloat recommendLabelY = beginY - recommendLabelH - cutViewH;
    UILabel *recommendLabel = [[UILabel alloc]initWithFrame:CGRectMake(recommendLabelX, recommendLabelY, recommendLabelW, recommendLabelH)];
    recommendLabel.text = @"推荐标签";
    recommendLabel.font = [UIFont systemFontOfSize:14.0];
    recommendLabel.textColor = [UIColor blackColor];
    recommendLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:recommendLabel];
    
    //添加隔断的背景view
    CGFloat cutViewY = recommendLabelY - cutViewH*2.0;
    UIView *cutView = [[UIView alloc]initWithFrame:CGRectMake(0, cutViewY, [UIScreen mainScreen].bounds.size.width, cutViewH)];
    cutView.backgroundColor = [UIColor colorWithRed:(236)/255.0 green:(236)/255.0 blue:(236)/255.0 alpha:1.0];
    [self addSubview:cutView];
}


- (void)selectedButtonClicked:(TagButton *)button{
    NSInteger index = button.tag - SelectedButtonTag;
    
    //[self.notSelected addObject:self.haveSelected[index]];
    [self.haveSelected removeObjectAtIndex:index];
    _isNotFirstReload = YES;
    
    if (button.isOrNotExtraAddButton)
    {
        NSInteger test = button.tagInt;
        [self.selectedButtonBackArr removeObjectAtIndex:test];
    }
    
    [self setNeedsDisplay];
    
}


- (void)notSelectedButtonClicked:(TagButton *)button{
    NSInteger index = button.tag - NotSelectedButtonTag;
    [self.haveSelected insertObject:self.notSelected[index] atIndex:self.haveSelected.count];
    [self.selectedButtonBackArr addObject:[NSString stringWithFormat:@"%ld",(long)index]];
    
    //[self.notSelected removeObjectAtIndex:index];
    [self setNeedsDisplay];
    
    
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
