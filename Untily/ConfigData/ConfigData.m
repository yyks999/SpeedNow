//
//  ConfigData.m
//  GreatWall
//
//  Created by 杨翊楷 on 13-3-20.
//  Copyright (c) 2013年 BH Technology Co., Ltd. All rights reserved.
//

#import "ConfigData.h"

#include <sys/param.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#include <net/if.h>
#include <net/if_dl.h>
#include <net/if_types.h>
#include <net/route.h>
#include <netinet/if_ether.h>
#include <netinet/in.h>


#include <arpa/inet.h>

#include <err.h>
#include <errno.h>
#include <netdb.h>

#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#import "GDataXMLNode.h"


static ConfigData *_instance;

@implementation ConfigData

#pragma mark - ********************** INITIALIZE  *********************

/* 初始化单例对象 */
+ (id)shareInstance
{
    if (!_instance) {
        _instance = [[ConfigData alloc] init];
        [_instance setIsShowHint:NO];
        [_instance setIsNeedUpdate:NO];
        [_instance setIsUpdateTime:NO];
        [_instance setLocalInProvince:YES];
        [_instance setCountDown:0];
        [_instance setDriveDistance:0];
        [_instance setLocalCity:@""];
        _instance.speedInfo = [[UserInfoModel alloc] initWithDic:@{}];
    }
    return _instance;
}

/* 初始化网络状态 */
- (void)setIsShowHint:(BOOL)isShowHint
{
    _isShowHint = isShowHint;
}

- (BOOL)getIsShowHint
{
    return _isShowHint;
}

/* 初始化更新状态 */
- (void)setIsNeedUpdate:(BOOL)isNeedUpdate
{
    _isNeedUpdate = isNeedUpdate;
}

- (BOOL)getIsNeedUpdate
{
    return _isNeedUpdate;
}

#pragma mark - ********************** GET INFO  **********************

/* 获取用户id */
+ (NSString *)getUserId
{
    if([ConfigData getUserInfo])
    {
        UserInfoModel *model = [ConfigData getUserInfo];
        return model.userId;
    }
    else
    {
        return @"";
    }
}

/* 将获取的json数据写到沙盒中，方便查看数据 */
- (void)writeToPlist:(id)object fileName:(NSString *)fileName
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
//    NSLog(@"filePath:%@",filePath);
    [object writeToFile:filePath atomically:YES];
}

/* 将输入的秒数转换为 时:分:秒 格式 */
+ (NSString *)getFullTimeBySecond:(int)allSecond
{
    int hourValue = allSecond / 3600;
    int minuteValue = allSecond % 3600 / 60;
//    int secondValue = allSecond % 3600 % 60;
    
    NSString *hour   = (hourValue >= 10)   ? [NSString stringWithFormat:@"%d",hourValue]   : [NSString stringWithFormat:@"%d",hourValue];
    NSString *minute = (minuteValue >= 10) ? [NSString stringWithFormat:@"%d",minuteValue] : [NSString stringWithFormat:@"0%d",minuteValue];
//    NSString *second = (secondValue >= 10) ? [NSString stringWithFormat:@"%d",secondValue] : [NSString stringWithFormat:@"0%d",secondValue];
    
    return [NSString stringWithFormat:@"%@:%@",hour, minute];
}

//获取启动应用时的时间
+ (NSString *)getStartingDate
{
    NSTimeInterval time_start = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVED_TIME];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time_start];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [dateFormatter  setDateFormat:@"HH:mm"];
    NSString *nowDateString = [dateFormatter stringFromDate:date];
    
    return nowDateString;
}

/* 返回系统日期 */
+ (NSString *)getSystemDateTime
{
    NSDate *  senddate=[NSDate date];
    NSCalendar  * cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    NSString *  nsDateString= [NSString  stringWithFormat:@"%ld-%ld-%ld",(long)year,(long)month,(long)day];
    
    return nsDateString;
}

/* 返回当前日期字符串 样式:2014-01-07 23:59:01 */
+ (NSString *)getNowDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];

    [dateFormatter  setDateFormat:@"HH:mm"];//yyyyMMddHHmmss
    
    //NSString *nowDateString = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:24*60*60]];

    NSString *nowDateString1 = [dateFormatter stringFromDate:[NSDate date]];
    //NSLog(@"%@",nowDateString1);
    return nowDateString1;
}

/* 当前时间，精确到毫秒 */
+ (NSString *)getNowDatePreciseString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [dateFormatter  setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *nowDateString1 = [dateFormatter stringFromDate:[NSDate date]];
    return nowDateString1;
}

/* 将时间格式化为yyyyMMddHHmmss */
+ (NSString *)formatDateWithoutPunctuation:(NSString *)string
{
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate*inputDate = [inputFormatter dateFromString:string];
    
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *str= [outputFormatter stringFromDate:inputDate];
    
    return str;
}

/* 仿微信时间显示 */
+ (NSString *)formatDateText:(NSString *)string
{
    if(!string || [string isEqualToString:@""])
        return @"";
    
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    //    [inputFormatter setDateFormat:@"yyyy年MM月dd日 HH时mm分ss秒"];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate*inputDate = [inputFormatter dateFromString:string];
    //    NSLog(@"startDate= %@", inputDate);
    
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //get date str
    NSString *str= [outputFormatter stringFromDate:inputDate];
    //str to nsdate
    NSDate *strDate = [outputFormatter dateFromString:str];
    //修正8小时的差时
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: strDate];
    NSDate *endDate = [strDate  dateByAddingTimeInterval: interval];
    //NSLog(@"endDate:%@",endDate);
    NSString *lastTime = [ConfigData compareDate:endDate];
    //    NSLog(@"lastTime = %@",lastTime);
    return lastTime;
}

/* 判断今天、昨天、前天 */
+ (NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    //修正8小时之差
    NSDate *date1 = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date1];
    NSDate *localeDate = [date1  dateByAddingTimeInterval: interval];
    
    //NSLog(@"nowdate=%@\nolddate = %@",localeDate,date);
    NSDate *today = localeDate;
    NSDate *yesterday,*beforeOfYesterday;
    //今年
    NSString *toYears;
    
    toYears = [[today description] substringToIndex:4];
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    beforeOfYesterday = [yesterday dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString *todayString = [[today description] substringToIndex:10];
    NSString *yesterdayString = [[yesterday description] substringToIndex:10];
    NSString *beforeOfYesterdayString = [[beforeOfYesterday description] substringToIndex:10];
    
    NSString *dateString = [[date description] substringToIndex:10];
    NSString *dateYears = [[date description] substringToIndex:4];
    
    NSString *dateContent;
    if ([dateYears isEqualToString:toYears])
    {
        //同一年
        //今 昨 前天的时间
        NSString *time = [[date description] substringWithRange:(NSRange){11,5}];
        //其他时间
        NSString *time2 = [[date description] substringWithRange:(NSRange){5,11}];
        if ([dateString isEqualToString:todayString]){
            dateContent = [NSString stringWithFormat:@"今天 %@",time];
            return dateContent;
        } else if ([dateString isEqualToString:yesterdayString]){
            dateContent = [NSString stringWithFormat:@"昨天 %@",time];
            return dateContent;
        }else if ([dateString isEqualToString:beforeOfYesterdayString]){
            dateContent = [NSString stringWithFormat:@"前天 %@",time];
            return dateContent;
        }else{
            return time2;
        }
    }else{
        return dateString;
    }
}

/* 客户端设备信息 */
+ (NSMutableDictionary *)getDeviceInfo
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier    = networkInfo.subscriberCellularProvider;      //运营商信息
    NSString *carrierType = @"中国电信";
    if([carrier.carrierName isEqualToString:@"中国电信"])
    {
        carrierType = @"chinanet";
    }else if ([carrier.carrierName isEqualToString:@"中国移动"])
    {
        carrierType = @"cmcc";
    }else if ([carrier.carrierName isEqualToString:@"中国联通"])
    {
        carrierType = @"chinaunicom";
    }
    
    NSString *pixel = [NSString stringWithFormat:@"%.fx%.f",[[UIScreen mainScreen] bounds].size.height * 2, [[UIScreen mainScreen] bounds].size.width * 2];
    
    //NSString *state      = [[UIDevice currentDevice] stringWithUUID]; //重生成随机唯一标识
    NSString *deviceCode = [[[UIDevice currentDevice] identifierForVendor] UUIDString];                                                    //设备唯一标识
    
    NSString *deviceTime    = [ConfigData getNowDateString];            //客户端时间
    NSString *deviceType    = [ConfigData platformString];              //客户端机型
    NSString *deviceVersion = [NSString stringWithFormat:@"ios%@",[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0]];            //客户端操作系统版本
    NSString *version = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];                              //当前版本号
    
    [dic setObject:deviceCode          forKey:@"sys_id"];
    [dic setObject:deviceTime          forKey:@"time"];
    [dic setObject:deviceType          forKey:@"mode_numb"];
    [dic setObject:@"apple"            forKey:@"brand"];
    [dic setObject:pixel               forKey:@"reso_rati"];
    [dic setObject:carrierType         forKey:@"t_mobile"];
    [dic setObject:deviceVersion       forKey:@"os_vers"];
    [dic setObject:version             forKey:@"soft_vers"];
    
    return dic;
}

/* 比较得出较晚的时间 */
+ (NSString *)isLaterTimeWithOldTime:(NSString *)oldTime newTime:(NSString *)newTime
{
    if([oldTime isEqualToString:@"0"])
        return newTime;
    
    NSDateFormatter *oldTimeFormatter= [[NSDateFormatter alloc] init];
    [oldTimeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    [oldTimeFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *oldDate = [oldTimeFormatter dateFromString:oldTime];
    
    NSDateFormatter *newTimeFormatter= [[NSDateFormatter alloc] init];
    [newTimeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
    //    [newTimeFormatter setLocale:[NSLocale currentLocale]];
    [newTimeFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *newDate = [oldTimeFormatter dateFromString:newTime];
    
    //比较时间的先后
    if([[oldDate laterDate:newDate] isEqualToDate:newDate])
    {
        return newTime;
    }
    else
    {
        return oldTime;
    }
}

/* 客户端设备类型 */
+ (NSString *)platformString{
    NSString *platform = [self getDeviceVersion];
    
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return @"iphone";
    if ([platform isEqualToString:@"iPhone1,2"])   return @"iphone3g";
    if ([platform isEqualToString:@"iPhone2,1"])   return @"iphone3gs";
    if ([platform isEqualToString:@"iPhone3,1"])   return @"iphone4";   //@"iphone4(移动,联通)";
    if ([platform isEqualToString:@"iPhone3,2"])   return @"iphone4";   //@"iphone4(联通)";
    if ([platform isEqualToString:@"iPhone3,3"])   return @"iphone4";   //@"iphone4(电信)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iphone4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iphone5";   //@"iphone5(移动,联通)";
    if ([platform isEqualToString:@"iPhone5,2"])   return @"iphone5";   //@"iphone5(移动,电信,联通)";
    if ([platform isEqualToString:@"iPhone5,3"])   return @"iphone5c";
    if ([platform isEqualToString:@"iPhone6,1"])   return @"iphone5s";
    if ([platform isEqualToString:@"iPhone6,2"])   return @"iphone5s";
    if ([platform isEqualToString:@"iPhone7,1"])   return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,2"])   return @"iPhone 6 Plus";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return @"ipod touch";
    if ([platform isEqualToString:@"iPod2,1"])     return @"ipod touch 2";
    if ([platform isEqualToString:@"iPod3,1"])     return @"ipod touch 3";
    if ([platform isEqualToString:@"iPod4,1"])     return @"ipod touch 4";
    if ([platform isEqualToString:@"iPod5,1"])     return @"ipod touch 5";
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return @"ipad 1";
    if ([platform isEqualToString:@"iPad2,1"])     return @"ipad 2(Wifi)";
    if ([platform isEqualToString:@"iPad2,2"])     return @"ipad 2(GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return @"ipad 2(CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return @"ipad 2(32nm)";
    if ([platform isEqualToString:@"iPad2,5"])     return @"ipad mini(Wifi)";
    if ([platform isEqualToString:@"iPad2,6"])     return @"ipad mini(GSM)";
    if ([platform isEqualToString:@"iPad2,7"])     return @"ipad mini(CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])     return @"ipad 3(Wifi)";
    if ([platform isEqualToString:@"iPad3,2"])     return @"ipad 3(CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return @"ipad 3(4G)";
    if ([platform isEqualToString:@"iPad3,4"])     return @"ipad 4(Wifi)";
    if ([platform isEqualToString:@"iPad3,5"])     return @"ipad 4(4G)";
    if ([platform isEqualToString:@"iPad3,6"])     return @"ipad 4(CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])     return @"iPad air(Wifi)";
    if ([platform isEqualToString:@"iPad4,2"])     return @"iPad air(4G)";
    if ([platform isEqualToString:@"iPad4,3"])     return @"iPad air(CDMA)";
    if ([platform isEqualToString:@"iPad4,4"])     return @"iPad mini 2(Wifi)";
    if ([platform isEqualToString:@"iPad4,5"])     return @"iPad mini 2(4G)";
    if ([platform isEqualToString:@"iPad4,6"])     return @"iPad mini 2(CDMA)";
    if ([platform isEqualToString:@"iPad4,7"])     return @"iPad mini 3(Wifi)";
    if ([platform isEqualToString:@"iPad4,8"])     return @"iPad mini 3(4G)";
    if ([platform isEqualToString:@"iPad4,9"])     return @"iPad mini 3(CDMA)";
    if ([platform isEqualToString:@"iPad5,3"])     return @"iPad air 2(Wifi)";
    if ([platform isEqualToString:@"iPad5,4"])     return @"iPad air 2(4G)";
    
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"iPhone Simulator"] || [platform isEqualToString:@"x86_64"]) return @"Simulator";
    
    return platform;
}

/* 获取版本code */
+ (NSString *)getVersionCode
{
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"BundleVersionCode" ofType:@"plist"];
    NSDictionary *eventData = [[NSDictionary alloc] initWithContentsOfFile:dataPath];
    NSString *version = [eventData getStringValueForKey:@"BundleVersionCode" defaultValue:@"0"];
    
    return version;
}

/* 获取缓存个人信息 */
+ (UserInfoModel *)getUserInfo
{
    NSData *userInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    if(userInfoData)
    {
        UserInfoModel *model = (UserInfoModel *)[NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
        return model;
    }else
    {
        return nil;
    }
}

/* 获取城市列表 */
+ (NSArray *)getCityInfo
{
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSDictionary *cityData = [[NSDictionary alloc] initWithContentsOfFile:dataPath];
    NSArray *cityInfo = [cityData objectForKey:@"Citys"];
    
    return cityInfo;
}

/* 根据城市名称获取城市Code */
+ (NSString *)getCityCodeFromCity:(NSString *)cityName
{
    NSString *cityCode = nil;   //如果不存在默认沈阳
    NSArray *cityInfo = [ConfigData getCityInfo];
    for (NSDictionary *dic in cityInfo)
    {
        if([cityName isEqualToString:[[dic allKeys] objectAtIndex:0]])
        {
            cityCode = [[dic allValues] objectAtIndex:0];
            return cityCode;
        }
    }
    
    return cityCode;
}

/* 根据城市Code获取城市名称 */
+ (NSString *)getCityFromCityCode:(NSString *)cityCode
{
    NSString *cityName = nil;   //如果不存在默认沈阳
    NSArray *cityInfo = [ConfigData getCityInfo];
    for (NSDictionary *dic in cityInfo)
    {
        if([cityCode isEqualToString:[[dic allValues] objectAtIndex:0]])
        {
            cityName = [[dic allKeys] objectAtIndex:0];
            return cityName;
        }
    }
    
    return cityName;
}


#pragma mark - ********************  SYSTEM TOOL  *******************

//16进制颜色转UIColor
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

/* 全局倒计时 */
+ (void)countDownContinue
{
    __block int timeout = [[ConfigData shareInstance] countDown]; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [[ConfigData shareInstance] setCountDown:timeout];
            });
        }else{
            //int minutes = timeout / 60;-
            int seconds = timeout % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //                NSLog(@"____%d",seconds);
                [[ConfigData shareInstance] setCountDown:seconds];
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}

/* GData解析XML */
+ (void)analysisWithXml:(NSString *)xmlStr
{
    GDataXMLDocument* document = [[GDataXMLDocument alloc] initWithHTMLString:xmlStr error:nil];
    GDataXMLElement* rootElement = [document rootElement];
    GDataXMLElement* bodyElement = [[rootElement elementsForName:@"body"]objectAtIndex:0];
    
    NSString *jsonStr;
    NSArray *strArray = [[bodyElement description] componentsSeparatedByString:@"<!--"];
    if(xmlStr && strArray.count > 1)
    {
        jsonStr = [[[strArray objectAtIndex:1] componentsSeparatedByString:@"-->"] objectAtIndex:0];
        id idJson = [jsonStr JSONValue];
        if (idJson == nil) {
            [ConfigData showToastWithMessage:@"json解析失败" showTime:TOSATTIME];
            return;
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:idJson];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:HTML_XML];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/* 判断Model是否相同 */
+ (BOOL)isSameModelWithOld:(id)oldModel new:(id)newModel
{
    UserInfoModel *oldInfo = (UserInfoModel *)oldModel;
    UserInfoModel *newInfo = (UserInfoModel *)newModel;
    
    if(![oldInfo.headImage isEqualToString:newInfo.headImage] || ![oldInfo.nickName isEqualToString:newInfo.nickName] || ![oldInfo.gender isEqualToString:newInfo.gender] || ![oldInfo.district isEqualToString:newInfo.district])
    {
        return NO;
    }
    
    return YES;
}

/* 计算字符串长度 */
- (int)textLength:(NSString *)text
{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++)
    {
        //一个汉字两个字节，应是+2.项目中数据库使用的mysql-utf8 一个汉字是3个字节，改成+3
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3){
            number += 3;
        }else{
            number ++;
        }
    }
    return ceil(number);
}

/* 文字正则 */
+(BOOL)isValidateUserName:(NSString *)userName
{
    NSString *userNameRegex = @"^[0-9a-zA-Z_]{4,16}$";
    
    NSPredicate *userNameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
    
    return [userNameTest evaluateWithObject:userName];
}

+(BOOL)isValidatePassword:(NSString *)pass
{
    NSString *passRegex = @"^[0-9a-zA-Z_@#$%&*]{4,16}$";
    
    NSPredicate *passTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passRegex];
    
    return [passTest evaluateWithObject:pass];
}

+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateMobilephone:(NSString *)mobilephone
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    
    NSString *mobilephoneRegex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    
    NSPredicate *mobilephoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobilephoneRegex];
    
    return [mobilephoneTest evaluateWithObject:mobilephone];
}

+ (BOOL)isValidateTelephone:(NSString *)telephone
{
    //数字 减号 之外的特殊字符都不能包含
    NSString *telephoneRegex = @"^[0-9\u4E00-\u9FA5-]+$";
    
    NSPredicate *telephoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telephoneRegex];
    
    return [telephoneTest evaluateWithObject:telephone];
}

/* 把格式化的JSON格式的字符串转换成字典 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}



#pragma mark - ***********************  UI TOOL  ************************

/* 创建按钮（包括设置标题、事件、背景颜色、高亮颜色、边框、边框颜色） */
+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title target:(SEL)tar class:(id)tarClass bgColor:(UIColor *)bgColor bgHeightLightColor:(UIColor *)bgHeightLightColor borderWidth:(float)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(float)cornerRadius
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];//[[UIButton alloc] initWithFrame:frame];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    btn.layer.borderColor  = borderColor.CGColor;
    btn.layer.borderWidth  = borderWidth;
    btn.layer.cornerRadius = cornerRadius;
    [btn addTarget:tarClass action:tar forControlEvents:UIControlEventTouchUpInside];
    
    if(bgColor)
    {
        UIImage *buttonImage = [UIImage createImageWithBgColor:bgColor size:CGSizeMake(frame.size.width, frame.size.height) cornerRadius:cornerRadius];
        [btn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
    
    if(bgHeightLightColor)
    {
        UIImage *buttonHignlightImage = [UIImage createImageWithBgColor:bgHeightLightColor size:CGSizeMake(frame.size.width, frame.size.height) cornerRadius:cornerRadius];
        [btn setBackgroundImage:buttonHignlightImage forState:UIControlStateHighlighted];
        [btn setBackgroundImage:buttonHignlightImage forState:UIControlStateSelected];
    }
    
    return btn;
}

/* 创建标签 */
+ (UILabel *)createLableWithFrame:(CGRect)frame text:(NSString *)txt fontSize:(int)size textColor:(UIColor *)textColor
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = textColor;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = txt;
    return label;
}

/* 创建ImageView */
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image
{
    UIImageView * imageview = [[UIImageView alloc] initWithFrame:frame];
    imageview.image = image;
    return imageview;
}

/* 为目标View添加边框和阴影效果 */
+ (UIView *)changeViewStyle:(UIView *)changeView
{
    //changeView.layer.borderWidth = 1;
    //changeView.layer.borderColor = [UIColor grayColor].CGColor;
    changeView.layer.shadowColor = [UIColor blackColor].CGColor;
    changeView.layer.shadowOpacity = 0.5f;
    changeView.layer.shadowOffset = CGSizeMake(2, 2);
    changeView.layer.shadowRadius = 2.0f;
    changeView.layer.masksToBounds = NO;
    changeView.layer.cornerRadius = 3.0f;
    
    return changeView;
}

/* 淡入淡出效果的HUD提示框 */
+ (void)showToastWithMessage:(NSString *)message showTime:(float)interval
{
    TipLabel * tip = [[TipLabel alloc] init];
    [tip showToastWithMessage:message showTime:interval];
}

/* 系统alert提示框 */
+ (void)showWcAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [WCAlertView showAlertWithTitle:title message:message customizationBlock:^(WCAlertView *alertView)
     {
         alertView.style = WCAlertViewStyleWhite;
     }
                    completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        
                    } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
}

/* 压缩图片到指定Size */
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = newSize.width;
    CGFloat targetHeight = newSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, newSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(newSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

/* 获取view所在的VC */
+ (UIViewController*)viewController:(UIView *)view
{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    UIView* next = [view superview];
    next = next.superview;
    
    return nil;  
}

#pragma mark - **************************  WIFI  **************************

/* 获取当前WIFI的SSID */
+ (NSString *)getDeviceSSID
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    
    id info = nil;
    for (NSString *ifnam in ifs)
    {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count])
        {
            break;
        }
    }
    
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [dctySSID objectForKey:@"SSID"];
    return ssid;
}

//可通过苹果review
+ (NSString*)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    //NSString *platform = [NSStringstringWithUTF8String:machine];二者等效
    free(machine);
    return platform;
}

/* 匹配SSID */
+ (NSString *)currentSSIDName:(NSString *)ssid
{
    if(!ssid || [ssid isEqualToString:@""])
        return @"00000000";
    
    if([ssid isEqualToString:@"CMCC"])
        return @"00";
    
    if([ssid isEqualToString:@"i-LiaoNing"])
        return @"01";
    
    if([ssid isEqualToString:@"MyWiFi"])
        return @"02";
    
    //    if([[ConfigData getDeviceSSID] rangeOfString:@"i-LiaoNing-Free"].length >= 15)
    //        return @"i-LiaoNing-Free";
    
    return ssid;
}


#pragma mark - **************************  SPEED  **************************

/* 存储记录的位置点 */
+ (void)updateLocationInfoWith:(NSMutableArray *)locations
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (CLLocation *c in locations) {
        
        NSDictionary *dic = @{@"longitude" : [NSString stringWithFormat:@"%f", c.coordinate.longitude],
                              @"latitude"  : [NSString stringWithFormat:@"%f", c.coordinate.latitude]};
        [array addObject:dic];
    }
    NSArray *locationArray = [NSArray arrayWithArray:array];
    [[NSUserDefaults standardUserDefaults] setObject:locationArray forKey:SAVED_LOCATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/* 读取记录的位置点 */
+ (NSArray *)getSaveLocationInfo
{
    NSArray *saveArray = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_LOCATION];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *d in saveArray) {
        
        float latitude  = [d getFloatValueForKey:@"latitude"  defaultValue:0];
        float longitude = [d getFloatValueForKey:@"longitude" defaultValue:0];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [array addObject:location];
    }
    
    return [NSArray arrayWithArray:array];
}


@end
