//
//  ImageDetailViewController.m
//  jianfanjia
//
//  Created by JYZ on 15/11/2.
//  Copyright © 2015年 JYZ. All rights reserved.
//

#import "BeautifulImageHomePageViewController.h"

@interface BeautifulImageHomePageViewController ()

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriateButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *imgDescription;
@property (weak, nonatomic) IBOutlet UILabel *imgTag;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomToSuper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarViewTopToSuper;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewArray;
@property (nonatomic, strong) NSMutableArray<UIScrollView *> *subscrollViewArray;

@property (nonatomic, strong) BeautifulImage *beautifulImage;
@property (nonatomic, strong) BeautifulImage *preBeautifulImage;
@property (nonatomic, strong) BeautifulImage *nextBeautifulImage;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger total;

@property (nonatomic, assign) BOOL isHidden;

@end

@implementation BeautifulImageHomePageViewController

#pragma mark - init method
- (id)initWithBeautifulImage:(BeautifulImage *)beautifulImage index:(NSInteger)index {
    if (self = [super init]) {
        _beautifulImage = beautifulImage;
        _index = index;
    }
    
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    [self initUI];
    [self getHomepage:self.beautifulImage._id];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self initDefaultNavBarStyle];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - ui
- (void)initNav {
    [self initLeftBackInNav];
    
    @weakify(self);
    [self.favoriateButton addTapBounceAnimation:^{
        @strongify(self);
        [self onClickFavoriteButton];
    }];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)initRightNaviBarItems {
    if ([self.beautifulImage.is_my_favorite boolValue]) {
        [self.favoriateButton setImage:[UIImage imageNamed:@"beautiful_img_favoriate_yes"] forState:UIControlStateNormal];
    } else {
        [self.favoriateButton setImage:[UIImage imageNamed:@"beautiful_img_favoriate_no"] forState:UIControlStateNormal];
    }
}

- (void)initUI {
    [self initRightNaviBarItems];
    self.imgDescription.text = nil;
    self.imgTag.text = nil;
    self.btnDownload.hidden = YES;
    self.shareButton.enabled = NO;
    
    self.imageViewArray = [NSMutableArray arrayWithCapacity:3];
    self.subscrollViewArray = [NSMutableArray arrayWithCapacity:3];
    @weakify(self);
    for (int i = 0; i < 3; i++) {
        UIImageView *w1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [w1 setContentMode:UIViewContentModeScaleAspectFit];
        UIScrollView *s = [[UIScrollView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, kScreenHeight)];
        s.maximumZoomScale = 3;
        s.minimumZoomScale = 1;
        [s setContentSize:CGSizeMake(kScreenWidth,  kScreenHeight)];
        s.bounces = NO;
        s.bouncesZoom = NO;
        s.showsHorizontalScrollIndicator = NO;
        s.showsVerticalScrollIndicator = NO;
        s.delegate = self;
        [s addSubview:w1];
        [self.scrollView addSubview:s];
        [self.imageViewArray addObject:w1];
        [self.subscrollViewArray addObject:s];
    }
    
    [self.scrollView setContentSize:CGSizeMake(kScreenWidth * 3, kScreenHeight)];
    self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [self.scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [[self.btnDownload rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self onClickDownloadButton];
    }];
}

- (NSString *)reloadAllImage {
    [self resetUI];
    CGFloat offsetX = self.scrollView.contentOffset.x;
    NSString *preImageid = [self.preBeautifulImage leafImageAtIndex:0].imageid;
    NSString *curImageid = [self.beautifulImage leafImageAtIndex:0].imageid;
    NSString *nextImageid = [self.nextBeautifulImage leafImageAtIndex:0].imageid;
    NSString *currentBeautifulId;
    
    if (offsetX > kScreenWidth) { // 向右
        [self reloadImageView:self.imageViewArray[0] withImage:curImageid];
        [self reloadImageView:self.imageViewArray[1] withImage:nextImageid];
        [self reloadImageView:self.imageViewArray[2] withImage:preImageid];
        currentBeautifulId = self.nextBeautifulImage._id;
    } else if (offsetX < kScreenWidth) { // 向左
        [self reloadImageView:self.imageViewArray[0] withImage:nextImageid];
        [self reloadImageView:self.imageViewArray[1] withImage:preImageid];
        [self reloadImageView:self.imageViewArray[2] withImage:curImageid];
        currentBeautifulId = self.preBeautifulImage._id;
    } else {
        [self reloadImageView:self.imageViewArray[0] withImage:preImageid];
        [self reloadImageView:self.imageViewArray[1] withImage:curImageid];
        [self reloadImageView:self.imageViewArray[2] withImage:nextImageid];
        currentBeautifulId = self.beautifulImage._id;
    }
    
    self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
    self.titleLabel.text = [NSString stringWithFormat:@"%@/%@", @(self.index), @(self.total)];
    self.imgDescription.text = self.beautifulImage.title;
    self.imgTag.text = [[[self.beautifulImage.keywords componentsSeparatedByString:@","] map:^id(id obj) {
        return [NSString stringWithFormat:@"#%@", obj];
    }] join:@" "];
    
    return currentBeautifulId;
}

- (void)resetUI {
    [self initRightNaviBarItems];
    self.btnDownload.hidden = YES;
    self.shareButton.enabled = NO;
    [self.subscrollViewArray[1] setZoomScale:1];
}

- (void)reloadImageView:(UIImageView *)imgView withImage:(NSString *)imageid {
    @weakify(imgView);
    [imgView setImageWithId:imageid withWidth:kScreenWidth completed:^(UIImage *image, NSURL *url, JYZWebImageFromType from, JYZWebImageStage stage, NSError *error) {
        @strongify(imgView);
        if (error == nil) {
            CGFloat height = kScreenWidth / (image.size.width / image.size.height);
            if (!isnan(height)) {
                if (imgView == self.imageViewArray[1]) {
                    self.btnDownload.hidden = NO;
                    self.shareButton.enabled = YES;
                }
                
                imgView.frame = CGRectMake(0, (kScreenHeight - height) / 2, kScreenWidth, height);
            }
        }
    }];
}

#pragma mark - scroll view deleaget
- (CGPoint)nearestTargetOffset:(CGPoint)curOffset velocity:(CGPoint)velocity {
    CGPoint targetOffset;
    if (curOffset.x > kScreenWidth) {
        if (curOffset.x > kScreenWidth * 1.5 || velocity.x > 0) {
            targetOffset = CGPointMake(kScreenWidth * 2, curOffset.y);
        } else {
            targetOffset = CGPointMake(kScreenWidth, curOffset.y);
        }
    } else {
        if (curOffset.x < kScreenWidth * 0.5 || velocity.x < 0) {
            targetOffset = CGPointMake(0, curOffset.y);
        } else {
            targetOffset = CGPointMake(kScreenWidth, curOffset.y);
        }
    }
    
    return targetOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.scrollView) {
        CGPoint targetOffset = [self nearestTargetOffset:scrollView.contentOffset velocity:velocity];
        targetContentOffset->x = targetOffset.x;
        targetContentOffset->y = targetOffset.y;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.scrollView) {
        if (!decelerate) {
            CGFloat offsetX = self.scrollView.contentOffset.x;
            if (offsetX == 0 || offsetX == kScreenWidth * 2) {
                NSString *beautifulImageId = [self reloadAllImage];
                [self getHomepage:beautifulImageId];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat offsetX = self.scrollView.contentOffset.x;
        if (offsetX == 0 || offsetX == kScreenWidth * 2) {
            NSString *beautifulImageId = [self reloadAllImage];
            [self getHomepage:beautifulImageId];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat offsetX = self.scrollView.contentOffset.x;
        if (self.index == 1 && offsetX < kScreenWidth) {
            self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        } else if (self.index == self.total && offsetX > kScreenWidth) {
            self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) {
        return self.imageViewArray[1];
    } else {
        return nil;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = self.imageViewArray[1];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - user action
- (IBAction)onClickBackButton:(id)sender {
    [self onClickBack];
}

- (void)onClickFavoriteButton {
    if (![self.beautifulImage.is_my_favorite boolValue]) {
        FavoriteBeautifulImage *request = [[FavoriteBeautifulImage alloc] init];
        request._id = self.beautifulImage._id;
        
        [API favoriteBeautifulImage:request success:^{
            self.beautifulImage.is_my_favorite = @1;
            [self.favoriateButton setImage:[UIImage imageNamed:@"beautiful_img_favoriate_yes"] forState:UIControlStateNormal];
            [HUDUtil showSuccessText:@"收藏成功"];
        } failure:^{
            [HUDUtil showErrText:@"收藏失败"];
        } networkError:^{
            
        }];
    } else {
        UnfavoriteBeautifulImage *request = [[UnfavoriteBeautifulImage alloc] init];
        request._id = self.beautifulImage._id;
        
        [API unfavoriteBeautifulImage:request success:^{
            self.beautifulImage.is_my_favorite = @0;
            [self.favoriateButton setImage:[UIImage imageNamed:@"beautiful_img_favoriate_no"] forState:UIControlStateNormal];
            [HUDUtil showSuccessText:@"取消收藏成功"];
        } failure:^{
            [HUDUtil showErrText:@"取消收藏失败"];
        } networkError:^{
            
        }];
    }
}

- (IBAction)onClickShareButton:(id)sender {
    NSString *title = self.beautifulImage.title;
    UIImage *shareImage = [self.imageViewArray[1] image];
    NSString *imgid = [[self.beautifulImage leafImageAtIndex:0] imageid];
    NSString *imgLink = [StringUtil beautifulImageUrl:imgid title:title];
    NSString *description = [NSString stringWithFormat:@"我在简繁家发现一张%@风格的%@美图，感觉还不错，分享给大家！", [NameDict nameForDecStyle:self.beautifulImage.dec_style], self.beautifulImage.section];
    
    [[ShareManager shared] share:self topic:ShareTopicBeautifulImage image:shareImage title:title description:description targetLink:imgLink delegate:self];
}

- (void)onClickDownloadButton {
    [UIView playBounceAnimationFor:self.btnDownload block:^{
        UIImageView *imgView = self.imageViewArray[1];
        UIImageWriteToSavedPhotosAlbum(imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        [HUDUtil showSuccessText:@"保存到相册成功"];
    } else {
        [HUDUtil showErrText:@"保存到相册失败"];
    }
}

#pragma mark - gesture
- (void)onSingleTap {
    self.isHidden = !self.isHidden;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        self.navBarViewTopToSuper.constant = self.isHidden ? -44 : 20;
        self.textViewBottomToSuper.constant = self.isHidden ? -35 : 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)onDoubleTap:(UITapGestureRecognizer *)g {
    UIScrollView *subscrollView = self.subscrollViewArray[1];
    
    if (subscrollView.zoomScale > 1) {
        [subscrollView setZoomScale:1.0 animated:YES];
    } else {
        UIImageView *imgView = subscrollView.subviews[0];
        CGPoint touchPoint = [g locationInView:imgView];
        CGFloat newZoomScale = subscrollView.maximumZoomScale;
        CGFloat xsize = subscrollView.frame.size.width / newZoomScale;
        CGFloat ysize = subscrollView.frame.size.height / newZoomScale;
        [subscrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - api request
- (void)getHomepage:(NSString *)beautifulId {
    [HUDUtil showWait];
    GetBeautifulImageHomepage *request = [[GetBeautifulImageHomepage alloc] init];
    request._id = beautifulId;
    
    @weakify(self);
    [API getBeautifulImageHomepage:request success:^{
        @strongify(self);
        self.beautifulImage = [[BeautifulImage alloc] initWith:[DataManager shared].data];;
        self.beautifulImage.previous = [[BeautifulImagePosition alloc] initWith:[self.beautifulImage.data objectForKey:@"previous"]];
        self.beautifulImage.next = [[BeautifulImagePosition alloc] initWith:[self.beautifulImage.data objectForKey:@"next"]];
        self.index = self.beautifulImage.previous.total.integerValue + 1;
        self.total = self.index + self.beautifulImage.next.total.integerValue;
        self.preBeautifulImage = [self.beautifulImage.previous beautifulImageAtIndex:0];
        self.nextBeautifulImage = [self.beautifulImage.next beautifulImageAtIndex:0];
        
        [self reloadAllImage];
        [HUDUtil hideWait];
    } failure:^{
        [self reloadAllImage];
        [HUDUtil hideWait];
    } networkError:^{
        [self reloadAllImage];
        [HUDUtil hideWait];
    }];
}

@end
