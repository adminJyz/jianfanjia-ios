//
//  DesignerBusiness.h
//  jianfanjia
//
//  Created by JYZ on 15/11/14.
//  Copyright © 2015年 JYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesignerBusiness : NSObject

+ (void)setStars:(NSArray *)imageViewArray withStar:(double)star fullStar:(UIImage *)full emptyStar:(UIImage *)empty;
+ (void)setV:(UIImageView *)imageView withAuthType:(NSString *)authType;
+ (void)setIdCardCheck:(UIImageView *)imageView withAuthType:(NSString *)authType;
+ (void)setBaseInfoCheck:(UIImageView *)imageView withAuthType:(NSString *)authType;
+ (NSInteger)setStars:(NSArray *)imageViewArray withTouchStar:(UIImageView *)touchedStar fullStar:(UIImage *)full emptyStar:(UIImage *)empty ;
+ (void)displayStars:(NSArray *)imageViewArray withAmount:(NSInteger)amount fullStar:(UIImage *)full emptyStar:(UIImage *)empty;
+ (void)setAvatarHangings:(UIImageView *)imageView withTags:(NSArray *)tags;

+ (NSString *)designerTagTextByArr:(NSArray *)tags;
+ (UIColor *)designerTagColorByArr:(NSArray *)tags;
+ (UIColor *)designerTagColor:(NSString *)tag;
+ (BOOL)containsJiangXinDingZhiTag:(NSArray *)tags;

+ (UIColor *)authTypeColor:(NSString *)authType;
+ (CGFloat)getDesignerAuthProgress;

+ (BOOL)isDesignerAgreeLicense:(NSString *)agreeLicense;
+ (BOOL)isDesignerFinishFundationAuth;

@end
