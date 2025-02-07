//
//  NSString+Ex.m
//  jianfanjia
//
//  Created by JYZ on 15/9/1.
//  Copyright (c) 2015年 JYZ. All rights reserved.
//

#import "NSString+Ex.h"

@implementation NSString (EX)

/*
 Description: Change the first letter of a string to lowercase.
 */
-(NSString *)lowercaseFirstLetterString
{
    if (self.length>0) {
        return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] lowercaseString]];
    }
    return self;
}

/*
 Description: Get string from the begining to the given index.
 */
-(NSString *)substringWithoutLast:(NSUInteger)last
{
    if (last<=self.length) {
        return [self substringToIndex:self.length-last];
    }
    return @"";
}

- (BOOL)isEmpty {
    if([self length] == 0) { //string is empty or nil
        return YES;
    }
    
    if([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        //string is all whitespace
        return YES;
    }
    
    return NO;
}

- (NSString *)hmacSha1:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], cHMAC);
    
    return [[[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)replaceEmptyToPlus {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (NSString *)add:(NSInteger)add {
    NSInteger i = [self integerValue];
    NSNumber *number = @(i + add);
    return [number stringValue];
}

- (NSSet *)tags {
    NSArray *array = [self componentsSeparatedByString:@","];
    NSMutableSet *tags = [[NSMutableSet alloc] initWithCapacity:array.count];
    
    if (array == nil) {
        return tags;
    }
    
    for (NSString *tag in array) {
        if (![@"none" isEqualToString:[tag lowercaseString]] && ![tag isEmpty]) {
            [tags addObject:tag];
        }
    }
    
    return tags;
}

- (BOOL)isValidateEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (NSMutableAttributedString *)attrStrWithFont:(UIFont *)font color:(UIColor *)color {
    NSMutableDictionary *dic = [@{} mutableCopy];
    if (font) {
        dic[NSFontAttributeName] = font;
    }
    
    if (color) {
        dic[NSForegroundColorAttributeName] = color;
    }
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self];
    [attributedStr setAttributes:dic
                           range:NSMakeRange(0, self.length)];
    return attributedStr;
}

- (NSMutableAttributedString *)attrSubStr:(NSString *)subStr font:(UIFont *)font color:(UIColor *)color {
    NSMutableDictionary *dic = [@{} mutableCopy];
    if (font) {
        dic[NSFontAttributeName] = font;
    }
    
    if (color) {
        dic[NSForegroundColorAttributeName] = color;
    }
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self];
    [attributedStr setAttributes:dic
                           range:[self rangeOfString:subStr]];
    return attributedStr;
}

- (NSMutableAttributedString *)attrSubStr1:(NSString *)subStr1 font1:(UIFont *)font1 color1:(UIColor *)color1 subStr2:(NSString *)subStr2 font2:(UIFont *)font2 color2:(UIColor *)color2 {
    NSMutableDictionary *dic1 = [@{} mutableCopy];
    NSMutableDictionary *dic2 = [@{} mutableCopy];
    if (font1) {
        dic1[NSFontAttributeName] = font1;
    }
    
    if (color1) {
        dic1[NSForegroundColorAttributeName] = color1;
    }
    
    if (font2) {
        dic2[NSFontAttributeName] = font2;
    }
    
    if (color2) {
        dic2[NSForegroundColorAttributeName] = color2;
    }
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self];
    [attributedStr addAttributes:dic1 range:[self rangeOfString:subStr1]];
    [attributedStr addAttributes:dic2 range:[self rangeOfString:subStr2]];
    
    return attributedStr;
}

+ (CGSize)sizeWithConstrainedSize:(CGSize)constrainedSize font:(UIFont *)font maxLength:(NSInteger)maxLength {
    NSMutableString *str = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < maxLength; i++) {
        [str appendString:@"靠"];
    }
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str attributes:attributesDictionary];
    CGRect rect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    // Values are fractional -- you should take the ceilf to get equivalent values
    CGSize adjustedSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    return adjustedSize;
}

+ (BOOL)compareStrWithIgnoreNil:(NSString *)aString other:(NSString *)bString {
    return [aString ? aString : @"" isEqualToString:bString ? bString : @""];
}

@end
