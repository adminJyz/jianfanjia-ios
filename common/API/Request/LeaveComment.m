//
//  LeaveMessage.m
//  jianfanjia
//
//  Created by Karos on 15/11/23.
//  Copyright © 2015年 JYZ. All rights reserved.
//

#import "LeaveComment.h"

@implementation LeaveComment

@dynamic topicid;
@dynamic section;
@dynamic item;
@dynamic topictype;
@dynamic content;
@dynamic to_designerid;
@dynamic to_userid;
@dynamic to_commentid;

- (void)failure {
    [HUDUtil showErrText:[DataManager shared].errMsg];
}

@end
