//
//  UserInfoModel.h
//  iLiaoNing
//
//  Created by 杨翊楷 on 15/6/16.
//  Copyright (c) 2015年 YK Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *userId;           //userid
@property (nonatomic, strong) NSString *headImage;        //头像
@property (nonatomic, strong) NSString *nickName;         //昵称
@property (nonatomic, strong) NSString *gender;           //性别
@property (nonatomic, strong) NSString *district;         //地区
@property (nonatomic, strong) NSString *cityCode;         //地区编码
@property (nonatomic, strong) NSString *telephone;        //手机号码

@property (nonatomic, strong) NSArray  *locationArray;    //位置点信息
@property (nonatomic, strong) NSString *starting;         //出发地
@property (nonatomic, strong) NSString *destination;      //目的地
@property (nonatomic, assign) float     distance;         //行驶距离
@property (nonatomic, assign) float     avgConsumption;   //平均油耗
@property (nonatomic, assign) int       fuelConsumption;  //总油耗
@property (nonatomic, assign) int       avgSpeed;         //平均时速
@property (nonatomic, assign) int       topSpeed;         //最高时速
@property (nonatomic, assign) int       driveTime;        //行驶时间

@property (nonatomic, strong) NSString *zipCode;    //地区区号
@property (nonatomic, strong) NSString *inProvince; //是否在省内 1:是  0:不是

-(id)initWithDic:(NSDictionary *)dic;

@end
