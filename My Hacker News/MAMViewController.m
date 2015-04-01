//
//  MAMViewController.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-21.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "MAMViewController.h"
#import "MAMButton.h"
#import "MAMReaderViewController.h"
#import "MAMStoryTableViewCell.h"
#import "KGStatusBar.h"
#import "UIView+AnchorPoint.h"

@interface MAMViewController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, MAMStoryTableViewCellDelegate, ReaderViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MAMButton *trendingButton;
@property (weak, nonatomic) IBOutlet UIButton *latestButton;
@property (weak, nonatomic) IBOutlet UIButton *bestButton;


- (IBAction)changeSection:(id)sender;
- (IBAction)swipe:(id)sender;

@end

@implementation MAMViewController
{
    MAMHNController *_hnController;
    MAMReaderViewController *_readerView;
    NSArray *_items;
    int _selectedRow;
    int _currentSection;
}

// 设置状态栏是否隐藏
- (BOOL)perfersStatusBarHidden
{
    if ([MAMHNController isPad]) {
       return YES;
    }
    
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _hnController = [MAMHNController sharedController];
    _items = [_hnController loadStoriesFromCacheOfType:HNControllerStoryTypeTrending];
    _currentSection = 0;

    [_trendingButton setSelected:YES];
    
    UIEdgeInsets tableViewEdgeInsets = UIEdgeInsetsMake(0, 0, [MAMHNController isPad] ? 0 : 44, 0);
    [self.tableView setContentInset:tableViewEdgeInsets];
    [self.tableView setScrollIndicatorInsets:tableViewEdgeInsets];
    
    // 下拉刷新
    // 一开始就刷新，每次都刷新
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableViewController setTableView:self.tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [tableViewController setRefreshControl:refreshControl];

    // KVO
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    //  remove observe
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 一开始就显示滚动条
    [self.tableView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 观察到frame变化刷新列表
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 设置cell背景色
    [cell setBackgroundColor:cell.contentView.backgroundColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAMStoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell setDelegate:self];
    
    __weak MAMHNStory *story = _items[indexPath.row];
    [cell.title setText:story.title];
    [cell.subtitle setText:story.subtitle];
    [cell.description setText:story.description];
    [cell.footer setText:story.footer];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    if (_readerView == nil) {
        _readerView = [self.storyboard instantiateViewControllerWithIdentifier:@"readerView"];
        [_readerView setDelegate:self];
        [_readerView view];
    }
    if (![[_items[_selectedRow] title] isEqualToString:_readerView.story.title]) {
        [_readerView setStory:_items[_selectedRow]];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.navigationController pushViewController:_readerView animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static UIFont *font = nil;
//    if (!font) {
//        int fontSize = [MAMHNController isPad] ? 20 : 17;
//        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize];
//    }
//    
//    CGRect fontRect = [[_items[indexPath.row] title] boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.tableView.bounds) - 20, 90) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil];
//    return 130 + CGRectGetHeight(fontRect) + CGRectGetMinY(fontRect);
    
    return 171;
}

#pragma mark - MAMStoryTableViewCellDelegate
- (void)tableViewDidRecognizeLongPressGestureWithCell:(MAMStoryTableViewCell *)cell
{
   
}

#pragma mark - ReaderViewDelegate
- (void)readerExit
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh:(id)sender
{
    __weak MAMViewController *weakSelf = self;
    [_hnController loadStoriesOfType:_currentSection result:^(NSArray *results, HNControllerStoryType type, BOOL success) {
        if (!success) {
            [KGStatusBar showWithStatus:@"Connection to server failed" duration:1];
            if ([sender isKindOfClass:[UIRefreshControl class]]) {
                [(UIRefreshControl *)sender endRefreshing];
            }
            return;
        }
        
        _items = results;
        [weakSelf.tableView reloadData];
        if ([sender isKindOfClass:[UIRefreshControl class]]) {
            UIRefreshControl *refreshControl = sender;
            [refreshControl endRefreshing];
        }
    }];
}



- (IBAction)changeSection:(id)sender {
    CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    [stretchAnimation setToValue:[NSNumber numberWithDouble:1.02]];
    [stretchAnimation setRemovedOnCompletion:YES];
    [stretchAnimation setFillMode:kCAFillModeRemoved];
    [stretchAnimation setAutoreverses:YES];
    [stretchAnimation setDuration:0.15];
    [stretchAnimation setDelegate:self];
    if (_currentSection != [sender tag]) {
        [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.30];
    }
    [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    int anchorPointX = _currentSection > [sender tag] ? 0 : 1;
    if (_currentSection == 0 && [sender tag] == 0) {
        anchorPointX = 0;
    }
    [self.view setAnchorPoint:CGPointMake(anchorPointX, 0.5) forView:self.view];
    [self.view.layer addAnimation:stretchAnimation forKey:@"animations"];
    
    if (_currentSection != [sender tag]) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:(_currentSection > [sender tag]) ? kCATransitionFromLeft : kCATransitionFromRight];
        [animation setDuration:0.3f];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.tableView layer] addAnimation:animation forKey:nil];
    }
    
    _currentSection = [sender tag];
    NSString *title;
    switch (_currentSection) {
        case 0:
            title = @"Currently Trending";
            [_trendingButton setSelected:YES];
            [_latestButton setSelected:NO];
            [_bestButton setSelected:NO];
            break;
        case 1:
            title = @"Latest Submissions";
            [_trendingButton setSelected:NO];
            [_latestButton setSelected:YES];
            [_bestButton setSelected:NO];
            break;
        case 2:
            title = @"Cream of the Crop";
            [_trendingButton setSelected:NO];
            [_latestButton setSelected:NO];
            [_bestButton setSelected:YES];
            break;
        default:
            break;
    }
    [self.titleLabel setText:title];
    
    _items = [_hnController loadStoriesFromCacheOfType:_currentSection];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    
    __weak MAMViewController *weakSelf = self;
    [_hnController loadStoriesOfType:_currentSection result:^(NSArray *results, HNControllerStoryType type, BOOL success) {
        if (!success) {
            [KGStatusBar showWithStatus:@"Connection to server failed" duration:1];
            return;
        }
        if (type != _currentSection) {
            return;
        }
        _items = results;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - CAAnimationDelegate
// 重新设定锚点
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.view setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.view];
}

- (IBAction)swipe:(id)sender {
    UISwipeGestureRecognizer *swipe = sender;
    if (swipe.state == UIGestureRecognizerStateRecognized) {
        if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
            if (_currentSection == 1) {
                // 模拟点击按钮
                [_bestButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            if (_currentSection == 0) {
                [_latestButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
            if (_currentSection == 1) {
                [_trendingButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            if (_currentSection == 2) {
                [_latestButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

#pragma mark -
#pragma mark Gesture Recoginizer
// 不允许同时检测多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end

