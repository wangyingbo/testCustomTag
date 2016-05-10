//
//  ViewController.m
//  testCustomTag
//
//  Created by 王迎博 on 16/4/28.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "ViewController.h"
#import "YBCustomTagView.h"
#import "secondVC.h"


//屏幕的宽和高
#define FULL_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define FULL_SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
// 颜色
#define YBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]


#define cellID @"cellID"
#define tagViewButtonH 30
#define TagButtonSpaY 10 //两个tag之间竖直方向间距
#define perTagButtonH (tagViewButtonH + TagButtonSpaY) //增加一行增加的高度

@interface ViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
{
    CGFloat _cellH;
    CGRect _tagViewFrame;
    
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *havedSelectedArr;
@property (nonatomic, strong) NSArray *selectedButtonBackArr;
@property (nonatomic, strong) NSArray *notSelectedArr;
@property (nonatomic, strong) NSArray *handAddTagIndexArr;
@property (nonatomic, strong) YBCustomTagView *tagView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cellH = FULL_SCREEN_HEIGHT;
    _tagViewFrame = CGRectMake(0, 0, FULL_SCREEN_WIDTH, _cellH);
    
    self.notSelectedArr =@[@"6手续的风格",@"7saSh",@"8SDFSDFS3",@"9撒旦是是",@"0水电费的所发生的",@"结果是",@"这是士大夫的法",@"真是",@"是个问题爸爸",@"扯淡啊",@"好滴吧没啥大问题",@"哎呦呦，别介啊",@"傻干的蛋蛋",@"扯犊子呢",@"也是",@"对",@"队长别开枪是我",@"好滴吧",@"扯犊子玩意儿",@"嘿嘿嘿",@"好滴"];
    //self.havedSelectedArr = @[@"卧槽",@"要坏事儿了"];
    
    //第三步:响应通知。 haveSelected通知方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveSelectedMethod:) name:@"haveSelected" object:nil];
    
    //第三步:响应通知。 notSelected通知方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notSelectedMethod:) name:@"notSelected" object:nil];
    
    //设置collectionView
    [self initCollectionView];
    
    //添加右边的按钮
    [self addNextButton];
}


- (void)haveSelectedMethod:(NSNotification *)text
{
    //NSLog(@"haveSelected通知方法--删除一行");
    self.havedSelectedArr = text.userInfo[@"haveSelected"];
    self.selectedButtonBackArr = text.userInfo[@"haveSelectedSelectedButtonBackArr"];
    
    _cellH = _cellH-perTagButtonH;
    CGRect rect = self.tagView.frame;
    rect.size.height = rect.size.height+perTagButtonH;
    _tagViewFrame = rect;
    
    //NSLog(@"..........%f",_cellH);
    [self.collectionView reloadData];
}



- (void)notSelectedMethod:(NSNotification *)text
{
    //NSLog(@"notSelected通知方法--增加一行");
    self.havedSelectedArr = text.userInfo[@"notSelected"];
    self.selectedButtonBackArr = text.userInfo[@"selectedButtonBackArr"];
    
    _cellH = _cellH+perTagButtonH;
    CGRect rect = self.tagView.frame;
    rect.size.height = rect.size.height+perTagButtonH;
    _tagViewFrame = rect;
    
    //NSLog(@"..........%f",_cellH);
    [self.collectionView reloadData];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:@"haveSelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:@"notSelected"];
}

/**
 *  添加右上角继续按钮
 */
- (void)addNextButton
{
    UIButton *buildButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buildButton setTitle:@"下个" forState:UIControlStateNormal];
    buildButton.frame = CGRectMake(0,0, 40, 30);
    [buildButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [buildButton addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buildButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buildButton];
    self.navigationItem.rightBarButtonItem = buildButtonItem;
}
- (void)nextClick:(UIButton *)sender
{
    secondVC *vc = [[secondVC alloc]init];
    [vc.dataMutArr addObjectsFromArray:self.havedSelectedArr];
    [vc.handAddTagIndexArr addObjectsFromArray:self.handAddTagIndexArr];
    vc.block = ^(NSArray *arrayData,NSArray *arrayHandAdd){
        //在secondVC里手动添加标签的block回调
        self.havedSelectedArr = arrayData;
        self.handAddTagIndexArr = arrayHandAdd;
        
        [self.collectionView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  设置collectionView
 */
- (void)initCollectionView
{
    //创建布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    //创建CollectionView
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = FULL_SCREEN_WIDTH;
    CGFloat h = FULL_SCREEN_HEIGHT;
    CGRect frame = CGRectMake(x, y, w, h);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = YBColor(235, 236, 237);
    // 解决CollectionView的内容小于它的高度不能滑动的问题
    collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *firstCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    
    YBCustomTagView *view = [[YBCustomTagView alloc] initWithFrame:_tagViewFrame];
    view.backgroundColor = [UIColor whiteColor];
    view.tagViewButtonFont = 15;
    view.tagViewButtonHeight = tagViewButtonH;
    view.haveSelected = [NSMutableArray arrayWithArray:_havedSelectedArr];
    view.notSelected = [NSMutableArray arrayWithArray:self.notSelectedArr];
    view.selectedButtonBackArr = [NSMutableArray arrayWithArray:self.self.selectedButtonBackArr];
    view.handAddTagIndexArr = self.handAddTagIndexArr;
    view.block = ^(NSArray *haveSelected,NSArray *selectedBackArr,NSArray *handAddArr){
        self.havedSelectedArr = haveSelected;
        self.handAddTagIndexArr = handAddArr;
        self.selectedButtonBackArr = selectedBackArr;
        //YBCustomTagView里的block回调
        //NSLog(@"%@",self.havedSelectedArr);
    };
    
    [firstCell addSubview:view];
    self.tagView = view;
    
    
    return firstCell;
    
}


#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
}


# pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(FULL_SCREEN_WIDTH, _cellH);
    return size;
}
@end
