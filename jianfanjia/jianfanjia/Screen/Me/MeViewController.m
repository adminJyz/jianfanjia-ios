//
//  MeViewController.m
//  jianfanjia
//
//  Created by JYZ on 15/10/27.
//  Copyright © 2015年 JYZ. All rights reserved.
//

#import "MeViewController.h"
#import "SettingViewController.h"
#import "UserInfoViewController.h"
#import "ViewControllerContainer.h"
#import "MyFavoriateViewController.h"
#import "CustomerServiceViewController.h"

@interface MeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnNotification;
@property (weak, nonatomic) IBOutlet UIButton *btnFavoriateDesigner;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIImageView *userThumnail;

@property (assign, nonatomic) CGFloat originUserImageHeight;
@property (assign, nonatomic) BOOL isTabbarhide;

@end


@implementation MeViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.userThumnail setCornerRadius:self.userThumnail.frame.size.width / 2];
    [self.userThumnail setBorder:1 andColor:[[UIColor whiteColor] CGColor]];
    self.originUserImageHeight = CGRectGetHeight(self.userImageView.frame);
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initUIData];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isTabbarhide) {
        [self showTabbar];
    }
    
    @weakify(self);
    [[NotificationDataManager shared] subscribeAllUnreadCount:^(id value) {
        @strongify(self);
        self.btnNotification.badgeValue = [value intValue] > 0 ? [value stringValue] : nil;
        [self.btnNotification adjustBadgeToCloseText];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!self.isTabbarhide && self.navigationController.viewControllers.count > 1) {
        [self hideTabbar];
    }
}

#pragma mark - UI
- (void)initUIData {
    self.lblUsername.text = [GVUserDefaults standardUserDefaults].username;
    if ([GVUserDefaults standardUserDefaults].phone) {
        self.lblPhone.text = [NSString stringWithFormat:@"帐号：%@", [GVUserDefaults standardUserDefaults].phone];
    } else {
        self.lblPhone.hidden = YES;
    }
    
    [self.userImageView setImageWithId:[GVUserDefaults standardUserDefaults].imageid placeholderImage:[UIImage imageNamed:@"image_place_holder_3"]];
    [self.userThumnail setUserImageWithId:[GVUserDefaults standardUserDefaults].imageid];
}

#pragma mark - user action
- (IBAction)onClickNotification:(id)sender {
    [ViewControllerContainer showReminder:nil refreshBlock:nil];
}

- (IBAction)onClickFavoriateDesigner:(id)sender {
    MyFavoriateViewController *v = [[MyFavoriateViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:v animated:YES];
}

- (IBAction)onTapUserImageView:(id)sender {
    UserInfoViewController *v = [[UserInfoViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:v animated:YES];
}

- (IBAction)onClickContactCustomerService:(id)sender {
//    CustomerServiceViewController *v = [[CustomerServiceViewController alloc] init];
//    [self.navigationController pushViewController:[CustomerServiceViewController instance] animated:YES];
//    
    [ViewControllerContainer showMyComments];
}

- (IBAction)onClickSetting:(id)sender {
    SettingViewController *v = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:v animated:YES];
}

#pragma mark - scroll view  delegate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.userImageView.frame = CGRectMake(0, offsetY, CGRectGetWidth(self.userImageView.frame), self.originUserImageHeight - offsetY);
}

#pragma mark - Util
- (void)hideTabbar {
    if (!self.isTabbarhide) {
        self.isTabbarhide = YES;
        [UIView animateWithDuration:0.6 animations:^{
            self.tabBarController.tabBar.frame = CGRectOffset(self.tabBarController.tabBar.frame, 0, 50);
        }];
    }
}

- (void)showTabbar {
    if (self.isTabbarhide) {
        self.isTabbarhide = NO;
        [UIView animateWithDuration:0.6 animations:^{
            self.tabBarController.tabBar.frame = CGRectOffset(self.tabBarController.tabBar.frame, 0, -50);
        }];
    }
}

@end
