//
//  ConfigData.h
//  GreatWall
//
//  Created by 杨翊楷 on 13-3-20.
//  Copyright (c) 2013年 BH Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfoModel;
@class AdInfoModel;
@class PortalInfoModel;

@interface ConfigData : NSObject
{

}

@property (nonatomic, strong) UserInfoModel *speedInfo;      //当前速度信息

@property (nonatomic, assign) NetworkStatus netStatus;       //当前网络状态

@property (nonatomic, strong) NSString *appToken;            //token

@property (nonatomic, strong) NSString *netSSID;             //当前SSID

@property (nonatomic, assign) BOOL isShowHint;               //是否显示网络状态提示

@property (nonatomic, assign) BOOL isNeedUpdate;             //是否需要升级

@property (nonatomic, assign) BOOL localInProvince;          //当前位置是否在省内

@property (nonatomic, assign) BOOL isUpdateTime;             //是否需要再次获取时间戳

@property (nonatomic, strong) NSString *localCity;           //当前所在城市

@property (nonatomic, strong) NSString *preciseDate;         //精确到毫秒(3位)的时间

@property (nonatomic, strong) NSMutableDictionary *userInfoDic;  //用户信息

@property (nonatomic, assign) int   driveDistance;        //当前行驶距离
@property (nonatomic, assign) float localLongitude;  //当前经度
@property (nonatomic, assign) float localLatitude;   //当前纬度

@property (nonatomic, assign) int countDown;

#pragma mark - ********************** INITIALIZE  *********************

/* 初始化单例对象 */
+ (id)shareInstance;

/* 初始化网络状态 */
- (void)setIsShowHint:(BOOL)isShowHint;
- (BOOL)getIsShowHint;

/* 初始化更新状态 */
- (void)setIsNeedUpdate:(BOOL)isNeedUpdate;
- (BOOL)getIsNeedUpdate;


#pragma mark - ********************** GET INFO  **********************

/* 获取用户id */
+ (NSString *)getUserId;

/* 将获取的json数据写到沙盒中，方便查看数据 */
- (void)writeToPlist:(id)object fileName:(NSString *)fileName;

/* 将输入的秒数转换为 时:分:秒 格式 */
+ (NSString *)getFullTimeBySecond:(int)allSecond;

//获取启动应用时的时间
+ (NSString *)getStartingDate;

/* 返回系统日期 */
+(NSString *)getSystemDateTime;

/* 返回当前日期字符串 样式:2014-01-07 */
+(NSString *)getNowDateString;

/* 当前时间，精确到毫秒 */
+(NSString *)getNowDatePreciseString;

/* 将时间格式化为yyyyMMddHHmmss */
+ (NSString *)formatDateWithoutPunctuation:(NSString *)string;

/* 仿微信时间显示 */
+ (NSString *)formatDateText:(NSString *)string;

/* 比较得出较晚的时间 */
+ (NSString *)isLaterTimeWithOldTime:(NSString *)oldTime newTime:(NSString *)newTime;

/* 客户端设备信息 */
+ (NSMutableDictionary *)getDeviceInfo;

/* 客户端设备类型 */
+ (NSString *)platformString;

/* 获取版本code */
+ (NSString *)getVersionCode;

/* 获取缓存个人信息 */
+ (UserInfoModel *)getUserInfo;

/* 获取城市列表 */
+ (NSArray *)getCityInfo;

/* 根据城市名称获取城市Code */
+ (NSString *)getCityCodeFromCity:(NSString *)city;

/* 根据城市Code获取城市名称 */
+ (NSString *)getCityFromCityCode:(NSString *)cityCode;


#pragma mark - ********************  SYSTEM TOOL  *******************

/* 16进制颜色转UIColor */
+ (UIColor *)colorWithHexString:(NSString *)color;

/* 全局倒计时 */
+ (void)countDownContinue;

/* GData解析XML */
+ (void)analysisWithXml:(NSString *)xmlStr;

/* 判断Model是否相同 */
+ (BOOL)isSameModelWithOld:(id)oldModel new:(id)newModel;

/* 计算字符串长度 */
- (int)textLength:(NSString *)text;

/* 文字正则 */
+ (BOOL)isValidateUserName:(NSString *)userName;
+ (BOOL)isValidatePassword:(NSString *)pass;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isValidateMobilephone:(NSString *)mobilephone;
+ (BOOL)isValidateTelephone:(NSString *)telephone;

/* 把格式化的JSON格式的字符串转换成字典 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


#pragma mark - ***********************  UI TOOL  ************************

/* 创建按钮（包括设置标题、事件、背景颜色、高亮颜色、边框、边框颜色） */
+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title target:(SEL)tar class:(id)tarClass bgColor:(UIColor *)bgColor bgHeightLightColor:(UIColor *)bgHeightLightColor borderWidth:(float)borderWidth borderColor:(UIColor *)borderColor cornerRadius:(float)cornerRadius;

/* 创建标签 */
+(UILabel *)createLableWithFrame:(CGRect)frame text:(NSString *)txt fontSize:(int)size textColor:(UIColor *)textrColor;

/* 创建ImageView */
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image;

/* 为目标View添加边框和阴影效果 */
+ (UIView *)changeViewStyle:(UIView *)changeView;

/* 淡入淡出效果的HUD提示框 */
+ (void)showToastWithMessage:(NSString *)message showTime:(float)interval;

/* 系统alert提示框 */
+ (void)showWcAlertWithTitle:(NSString *)title message:(NSString *)message;

/* 压缩图片到指定Size */
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

/* 获取view所在的VC */
+ (UIViewController*)viewController:(UIView *)view;


#pragma mark - **************************  WIFI  **************************

/* 获取当前WIFI的SSID */
+ (NSString *)getDeviceSSID;

/* 匹配SSID */
+ (NSString *)currentSSIDName:(NSString *)ssid;


#pragma mark - **************************  SPEED  **************************

/* 存储记录的位置点 */
+ (void)updateLocationInfoWith:(NSMutableArray *)locations;

/* 读取记录的位置点 */
+ (NSArray *)getSaveLocationInfo;


@end
