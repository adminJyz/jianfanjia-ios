//
//  OrderDesignerViewController.h
//  jianfanjia
//
//  Created by Karos on 15/11/17.
//  Copyright © 2015年 JYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LeaveMessageViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithPlan:(Plan *)plan;
- (id)initWithProcess:(Process *)process section:(NSString *)section item:(NSString *)item block:(void(^)(void))RefreshBlock;

@end
