//
//  NSString+category.h
//  iLearning
//
//  Created by 杨翊楷 on 13-8-20.
//  Copyright (c) 2013年 iSoftstone infomation Technology (Group) Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (category)

/*字符串转 MD5*/
- (NSString *)stringFromMD5;
/*字符串转 sha1*/
- (NSString *)sha1;
/*字符加换行符号\n*/
- (NSString *)appNextLineKeyword:(NSString *)word;

/*获取字符串的长度*/
- (CGSize)getSizeOfStringFontSize:(int)fontSize constroSize:(CGSize)size;
- (CGSize)getSizeOfString:(UIFont *)font constroSize:(CGSize)size;

/*邮箱验证 MODIFIED BY HELENSONG*/
- (BOOL)isValidateEmail;
/*手机号码验证 MODIFIED BY HELENSONG*/
- (BOOL)isValidateMobile;
/*车牌号验证 MODIFIED BY HELENSONG*/
- (BOOL)validateCarNo;

//获取当前的时间字符串
+ (NSString *)getCurrentDateString;
//NSDate 转 NSString 
+ (NSString *)dateToString:(NSDate *)date;

//汉字编码
-(NSString *)URLEncodedString;


@end
