//
//  SnsAccountInfo.h
//  jianfanjia
//
//  Created by Karos on 16/1/6.
//  Copyright © 2016年 JYZ. All rights reserved.
//

@interface JYZSocialSnsAccountInfo : NSObject

/**
 用户昵称
 */
@property (nonatomic, strong) NSString *userName;

/**
 用户在微博的id号
 */
@property (nonatomic, strong) NSString *usid;

/**
 用户微博头像的url
 */
@property (nonatomic, strong) NSString *iconURL;

/**
 微信授权完成后得到的unionId
 
 */
@property (nonatomic, strong) NSString *unionId;

/**
 性别
 
 */
@property (nonatomic, strong) NSNumber *gender;

/**
 accessToken
 
 */
@property (nonatomic, strong) NSString *accessToken;



@end
