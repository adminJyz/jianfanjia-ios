//
//  ProcessViewController.m
//  jianfanjia
//
//  Created by JYZ on 15/9/16.
//  Copyright (c) 2015年 JYZ. All rights reserved.
//

#import "ProcessViewController.h"
#import "BannerCell.h"
#import "SectionView.h"
#import "ItemCell.h"
#import "ItemExpandImageCell.h"
#import "ItemExpandCheckCell.h"
#import "API.h"
#import "ProcessDataManager.h"
#import "ViewControllerContainer.h"
#import "ItemsBackgroundView.h"
#import "TouchDelegateView.h"

typedef NS_ENUM(NSInteger, WorkSiteMode) {
    WorkSiteModePreview,
    WorkSiteModeReal,
};

static NSString *ItemExpandCellIdentifier = @"ItemExpandImageCell";
static NSString *ItemExpandCheckCellIdentifier = @"ItemExpandCheckCell";
static NSString *ItemCellIdentifier = @"ItemCell";

@interface ProcessViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) TouchDelegateView *containerView;
@property (strong, nonatomic) UIScrollView *sectionScrollView;
@property (strong, nonatomic) NSMutableArray *sectionViewArr;

@property (strong, nonatomic) NSString *processid;
@property (assign, nonatomic) WorkSiteMode workSiteMode;
@property (strong, nonatomic) ProcessDataManager *dataManager;

@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (assign, nonatomic) BOOL isHeaderHidden;
@property (assign, nonatomic) BOOL isFirstEnter;

@end

@implementation ProcessViewController

#pragma mark - init method
- (id)initWithProcess:(NSString *)processid withMode:(WorkSiteMode)mode {
    if (self = [super init]) {
        _workSiteMode = mode;
        _processid = processid;
        _dataManager = [[ProcessDataManager alloc] init];
    }
    
    return self;
}

- (id)initWithProcess:(NSString *)processid {
    return [self initWithProcess:processid withMode:WorkSiteModeReal];
}

- (id)initWithProcessPreview {
    return [self initWithProcess:nil withMode:WorkSiteModePreview];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    [self initUI];
    [self refreshProcess:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NotificationDataManager shared] refreshUnreadCount];
    
    if (!self.isFirstEnter) {
        [self refreshForIndexPath:self.lastSelectedIndexPath isExpand:YES];
    }
}

#pragma mark - UI
- (void)initNav {
    [self initLeftBackInNav];
    self.title = @"工地管理";

    UIButton *bellButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [bellButton setImage:[UIImage imageNamed:@"notification-bell"] forState:UIControlStateNormal];
    [bellButton addTarget:self action:@selector(onClickMyNotification) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bellButton];
}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:ItemCellIdentifier bundle:nil] forCellReuseIdentifier:ItemCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:ItemExpandCellIdentifier bundle:nil] forCellReuseIdentifier:ItemExpandCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:ItemExpandCheckCellIdentifier bundle:nil] forCellReuseIdentifier:ItemExpandCheckCellIdentifier];
    [self configureHeaderToTableView:YES];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = [ItemsBackgroundView itemsBackgroundView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    self.tableView.contentInset = UIEdgeInsetsMake(64+SectionViewHeight, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.containerView = [[TouchDelegateView alloc] initWithFrame:CGRectMake(0, -SectionViewHeight, kScreenWidth, SectionViewHeight)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.tableView addSubview:self.containerView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SectionViewWidth, SectionViewHeight)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.alwaysBounceHorizontal = NO;
    scrollView.clipsToBounds = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    
    self.sectionScrollView = scrollView;
    [self.containerView addSubview:scrollView];
    self.containerView.touchDelegateView = scrollView;
    
    self.isFirstEnter = YES;
    
    [[NotificationDataManager shared] subscribeMyNotificationUnreadCount:^(NSInteger count) {
        self.navigationItem.rightBarButtonItem.badgeNumber = count > 0 ? kBadgeStyleDot : @"";
    }];
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.sectionScrollView) {
        if (!decelerate) {
            NSUInteger index = self.sectionScrollView.contentOffset.x / SectionViewWidth;
            NSUInteger curIndex = self.dataManager.selectedSectionIndex;
            if (index != curIndex) {
                [self reloadItemsForSection:index];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.sectionScrollView) {
        NSUInteger index = self.sectionScrollView.contentOffset.x / SectionViewWidth;
        NSUInteger curIndex = self.dataManager.selectedSectionIndex;
        if (index != curIndex) {
            [self reloadItemsForSection:index];
        }
    }
}

#pragma mark - getures
- (void)handleTapSectionViewGesture:(UITapGestureRecognizer *)gesture {
    SectionView *sectionView = (SectionView *)gesture.view;
    NSInteger index = [self.sectionViewArr indexOfObject:sectionView];
    [self.sectionScrollView setContentOffset:CGPointMake(index * SectionViewWidth, 0) animated:YES];
    [self reloadItemsForSection:index];
}

#pragma mark - table view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataManager.selectedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = self.dataManager.selectedItems[indexPath.row];
    
    if (item.itemCellStatus == ItemCellStatusClosed) {
        ItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ItemCellIdentifier forIndexPath:indexPath];
        [cell initWithItem:item withDataManager:self.dataManager];
        [self configureCellProperties:cell];
        return cell;
    } else {
        if ([item.name isEqualToString:DBYS]) {
            ItemExpandCheckCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ItemExpandCheckCellIdentifier forIndexPath:indexPath];
            @weakify(self);
            [cell initWithItem:item withDataManager:self.dataManager withBlock:^{
                @strongify(self);
                [self refreshForIndexPath:indexPath isExpand:YES];
            }];
            [self configureCellProperties:cell];
            return cell;
        } else {
            ItemExpandImageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ItemExpandCellIdentifier forIndexPath:indexPath];
            @weakify(self);
            [cell initWithItem:item withDataManager:self.dataManager withBlock:^(BOOL isNeedReload) {
                @strongify(self);
                if (isNeedReload) {
                    [self refreshForIndexPath:indexPath isExpand:YES];
                } else {
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                }
            }];
            [self configureCellProperties:cell];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataManager.selectedSection.status isEqualToString:kSectionStatusUnStart]) {
        self.lastSelectedIndexPath = indexPath;
        return;
    }
    
    if (self.lastSelectedIndexPath && self.lastSelectedIndexPath.row != indexPath.row) {
        Item *item = self.dataManager.selectedItems[indexPath.row];
        item.itemCellStatus = ItemCellStatusExpaned;
        
        Item *lastItem = self.dataManager.selectedItems[self.lastSelectedIndexPath.row];
        lastItem.itemCellStatus = ItemCellStatusClosed;
        
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.lastSelectedIndexPath, indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    } else  {
        Item *item = self.dataManager.selectedItems[indexPath.row];
        [item switchItemCellStatus];
        
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
    
    self.lastSelectedIndexPath = indexPath;
}

- (void)configureCellProperties:(UITableViewCell *)cell {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - refresh
- (void)configureHeaderToTableView:(BOOL)needConfigure {
    if (self.workSiteMode == WorkSiteModeReal && needConfigure) {
        if (!self.tableView.header) {
            @weakify(self);
            self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                @strongify(self);
                [self refreshProcess:NO];
            }];
            self.tableView.header.ignoredScrollViewContentInsetTop = SectionViewHeight;
        }
    } else {
        self.tableView.header = nil;
    }
}

- (void)refreshProcess:(BOOL)showPlsWait {
    if (self.workSiteMode == WorkSiteModePreview) {
        [self.dataManager refreshSections:[ProcessBusiness defaultProcess]];
        [self refreshSectionView];
        [self reloadItemsForSection:0];
    } else {
        if (showPlsWait) {
            [HUDUtil showWait];
        }
        GetProcess *request = [[GetProcess alloc] init];
        request.processid = self.processid;
        
        [API getProcess:request success:^{
            [HUDUtil hideWait];
            [self.tableView.header endRefreshing];
            [self.dataManager refreshProcess];
            [self refreshSectionView];
            [self scrollToOngoingSection];
            [self reloadItemsForSection:self.dataManager.selectedSectionIndex];
        } failure:^{
            [HUDUtil hideWait];
            [self.tableView.header endRefreshing];
        } networkError:^{
            [HUDUtil hideWait];
            [self.tableView.header endRefreshing];
        }];
    }
}

- (void)refreshForIndexPath:(NSIndexPath *)indexPath isExpand:(BOOL)isExpand {
    if (!indexPath) {
        return;
    }
    
    GetProcess *request = [[GetProcess alloc] init];
    request.processid = self.processid;
    
    [API getProcess:request success:^{
        [self.dataManager refreshProcess];
        [self refreshSectionView];
        BOOL goToNextSection = [self scrollToOngoingSection];
        if (goToNextSection) {
            [self reloadItemsForSection:self.dataManager.selectedSectionIndex];
        } else {
            [self.dataManager switchToSelectedSection:self.dataManager.selectedSectionIndex];
            Item *item = self.dataManager.selectedItems[indexPath.row];
            if (isExpand) {
                item.itemCellStatus = ItemCellStatusExpaned;
            } else {
                item.itemCellStatus = ItemCellStatusClosed;
            }
            
            [self refreshSectionBackground];
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    } failure:^{
        
    } networkError:^{
        
    }];
}

#pragma mark - refresh section
- (void)refreshSectionView {
    if (self.isFirstEnter) {
        self.isFirstEnter = NO;
        self.title = self.dataManager.process.cell;
        [self initSectionView];
    } else {
        [self updateSectionView];
    }
}

- (BOOL)scrollToOngoingSection {
    if (self.dataManager.preOngoingSectionIndex == self.dataManager.ongoingSectionIndex) {
        return NO;
    }
    
    self.dataManager.selectedSectionIndex = self.dataManager.ongoingSectionIndex;
    [UIView animateWithDuration:0.5 animations:^{
        [self.sectionScrollView setContentOffset:CGPointMake(self.dataManager.selectedSectionIndex * SectionViewWidth, 0) animated:NO];
    }];

    return YES;
}

#pragma mark - update section
- (void)initSectionView {
    NSArray *sections = self.dataManager.sections;
    self.sectionViewArr = [NSMutableArray arrayWithCapacity:sections.count];
    self.sectionScrollView.contentSize = CGSizeMake(sections.count * SectionViewWidth, SectionViewHeight);
    
    @weakify(self);
    [sections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        Section *section = sections[idx];
        SectionView *sectionView = [SectionView sectionView];
        sectionView.frame = CGRectMake(idx * SectionViewWidth, 0, SectionViewWidth, SectionViewHeight);
        [sectionView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapSectionViewGesture:)]];
        
        [self updateSection:section forView:sectionView index:idx total:sections.count];
        [self.sectionScrollView addSubview:sectionView];
        [self.sectionViewArr addObject:sectionView];
    }];
}

- (void)updateSectionView {
    NSArray *sections = self.dataManager.sections;
    
    @weakify(self);
    [self.sectionViewArr enumerateObjectsUsingBlock:^(SectionView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        [self updateSection:sections[idx] forView:obj index:idx total:self.sectionViewArr.count];
    }];
}

- (void)updateSection:(Section *)section forView:(SectionView *)sectionView index:(NSInteger)index total:(NSInteger)total {
    if (index == 0) {
        sectionView.leftLine.hidden = YES;
    } else if (index == (total - 1)) {
        sectionView.rightLine.hidden = YES;
    }
    
    Section *preSection = self.dataManager.sections[index - 1 < 0 ? 0 : index - 1];
    Section *nextSection = self.dataManager.sections[index + 1 > total - 1 ? total - 1 : index + 1];
    if ([preSection.status isEqualToString:kSectionStatusAlreadyFinished] && [section.status isEqualToString:kSectionStatusAlreadyFinished]) {
        sectionView.leftLine.backgroundColor = kFinishedColor;
    }
    
    if ([section.status isEqualToString:kSectionStatusAlreadyFinished] && [nextSection.status isEqualToString:kSectionStatusAlreadyFinished]) {
        sectionView.rightLine.backgroundColor = kFinishedColor;
    }
    
    sectionView.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"section_%@_%d", @(index), section.status.intValue < 3 ? section.status.intValue : 1]];
    sectionView.nameLabel.text = [ProcessBusiness nameForKey:section.name];
    sectionView.durationLabel.text = [NSString stringWithFormat:@"%@-%@", [NSDate M_dot_dd:section.start_at], [NSDate M_dot_dd:section.end_at]];
}

#pragma mark - reload items
- (void)reloadItemsForSection:(NSInteger)sectionIndex {
    [self.dataManager switchToSelectedSection:sectionIndex];
    [self initItemsStatus];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)initItemsStatus {
    [self refreshSectionBackground];
    
    self.lastSelectedIndexPath = nil;
    if ([self.dataManager.selectedSection.status isEqualToString:kSectionStatusUnStart]) {
        return;
    }
    
    __block NSTimeInterval latestUpdateTime = 0;
    __block NSInteger latestUpdateItem = -1;
    __block NSInteger dbysItem = -1;
    __block NSInteger subSectionsFinishedCount = 0;
    [self.dataManager.selectedItems enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Item *  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval itemTime = item.date.doubleValue;
        if (itemTime > latestUpdateTime) {
            latestUpdateTime = itemTime;
            latestUpdateItem = idx;
        }
        
        if ([item.name isEqualToString:DBYS]) {
            dbysItem = idx;
        }
        
        if ([item.status isEqualToString:kSectionStatusAlreadyFinished]) {
            subSectionsFinishedCount++;
        }
    }];
    
    // 如果当前工序下的子工序都完工了，进入工地管理时，就要展开对比验收子工序。
    if (dbysItem >= 0 && subSectionsFinishedCount + 1 == self.dataManager.selectedItems.count) {
        latestUpdateItem = dbysItem;
    }
    
    [self.dataManager.selectedItems enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Item *  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (latestUpdateItem == idx) {
            item.itemCellStatus = ItemCellStatusExpaned;
        } else {
            item.itemCellStatus = ItemCellStatusClosed;
        }
    }];
    
    if (latestUpdateItem > -1) {
        self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:latestUpdateItem inSection:0];
    }
}

- (void)refreshSectionBackground {
    id backgroundView = self.tableView.backgroundView;
    if ([self.dataManager.selectedSection.status isEqualToString:kSectionStatusAlreadyFinished]) {
        [backgroundView statusLine].backgroundColor = kFinishedColor;
    } else {
        [backgroundView statusLine].backgroundColor = kUntriggeredColor;
    }
}

#pragma mark - user action
- (void)onClickMyNotification {
    [ViewControllerContainer showMyNotification];
}

@end
