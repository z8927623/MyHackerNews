//
//  MAMCommentsViewController.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-21.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "MAMCommentsViewController.h"

#import "MAMCommentTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "MAMWebViewController.h"

@interface MAMCommentsViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITabBarDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)back:(id)sender;
- (IBAction)headerTap:(id)sender;

@end

@implementation MAMCommentsViewController
{
    MAMHNController *_hnController;
    NSArray *_comments;
}

- (BOOL)prefersStatusBarHidden
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
    
    BOOL isPad = [MAMHNController isPad];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((isPad) ? 44 : 0, 0, (isPad) ? 0 : 44, 0);
    [self.tableView setScrollIndicatorInsets:edgeInsets];
    [self.tableView setContentInset:edgeInsets];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableViewController setTableView:self.tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithWhite:.75f alpha:1.0];
    [refreshControl addTarget:self action:@selector(loadComments:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refreshControl;
    
    self.titleLabel.text = @"Loading Comments...";
    [self loadComments:nil];
    
    // don't forget to remove in dealloc
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)loadComments:(id)sender
{
    // AFNetworking的写法
//    __weak __typeof(&*self)weakSelf = self;
    
    // 这么写
//    __weak __typeof(self) weakSelf = self;
    // 或者这么写
//    __weak XxxViewController *weakSelf = self;
    // 或者这么写
//    __weak id weakSelf = self;
    
    __weak typeof(self) weakSelf = self;
    [[MAMHNController sharedController] loadCommentsOnStoryWithID:_story.hnID result:^(NSArray *results) {
        if (!results.count) {
            [weakSelf.titleLabel setText:@"No Comments"];
            return;
        }
        _comments = results;
        [weakSelf.tableView reloadData];
        [weakSelf.tableView flashScrollIndicators];
        [weakSelf.titleLabel setText:self.story.title];
        if (sender) {
            [sender endRefreshing];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toWeb" sender:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/%@", [_comments[indexPath.row] replyID]]]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:cell.contentView.backgroundColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAMCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    MAMHNComment *comment = _comments[indexPath.row];
    cell.comment.textColor = comment.color;
    cell.comment.delegate = self;
    cell.comment.text = comment.comment;
    
    cell.user.text = comment.username;
    cell.time.text = comment.time;
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static float screenWidth;
    if (screenWidth == 0) {
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
    }
    MAMHNComment *hnComment = _comments[indexPath.row];
    float width = screenWidth - hnComment.indentationLevel * 10 - 20;
    
    return [MAMCommentTableViewCell heightForCellWithText:hnComment.comment constrainedToWidth:width];
}

- (int)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_comments[indexPath.row] indentationLevel];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [self performSegueWithIdentifier:@"toWeb" sender:url];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toWeb"]) {
        MAMWebViewController *webViewController = segue.destinationViewController;
        // 设置url
        [webViewController loadURL:sender];
    }
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Gesture Recognizer
// 允许同时检测多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)headerTap:(id)sender {
    UITapGestureRecognizer *tap = sender;
    if (tap.state == UIGestureRecognizerStateRecognized) {
        [self performSegueWithIdentifier:@"toWeb" sender:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@", _story.hnID]]];
    }
}

@end
