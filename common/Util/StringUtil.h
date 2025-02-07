//
//  StringUtil.h
//  jianfanjia
//
//  Created by JYZ on 15/12/4.
//  Copyright © 2015年 JYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtil : NSObject

+ (NSString *)convertNil2Empty:(NSString *)aStr;
+ (NSString *)rawImageUrl:(NSString *)imageid;
+ (NSString *)thumbnailImageUrl:(NSString *)imageid width:(NSInteger)width;
+ (NSString *)thumbnailImageUrl:(NSString *)imageid width:(NSInteger)width height:(NSInteger)height;
+ (NSString *)beautifulImageUrl:(NSString *)imageid title:(NSString *)title;
+ (NSString *)pcUrl:(NSString *)url;
+ (NSString *)mobileUrl:(NSString *)url;
+ (NSString *)escapeHtml:(NSString *)json;

@end
