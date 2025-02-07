//
//  PhotoCropper.h
//  jianfanjia
//
//  Created by Karos on 16/5/3.
//  Copyright © 2016年 JYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PhotoCropperStyle) {
    PhotoCropperStyleOriginal,
    PhotoCropperStyleSquare,
};

typedef void (^PhotoCropperCancelBlock)(void);
typedef void (^PhotoCropperChooseBlock)(UIImage *croppedImage);

@interface PhotoCropper : NSObject

+ (void)showPhotoCropper:(UIViewController *)controller image:(UIImage *)image style:(PhotoCropperStyle)style cancel:(PhotoCropperCancelBlock)cancelBlock choose:(PhotoCropperChooseBlock)chooseBlock;
+ (void)showPhotoCropper:(UIViewController *)controller asset:(PHAsset *)asset style:(PhotoCropperStyle)style cancel:(PhotoCropperCancelBlock)cancelBlock choose:(PhotoCropperChooseBlock)chooseBlock;

@end
