//
//  UserInfoModel.m
//  iLiaoNing
//
//  Created by 杨翊楷 on 15/6/16.
//  Copyright (c) 2015年 YK Yang. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

-(id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        NSString *sex    = [dic getStringValueForKey:@"gender"    defaultValue:@"1"];
        self.gender      = [sex isEqualToString:@"1"] ? @"男" : @"女";
        self.userId      = [dic getStringValueForKey:@"userId"    defaultValue:@""];
        self.headImage   = [dic getStringValueForKey:@"headImage" defaultValue:@""];
        self.nickName    = [dic getStringValueForKey:@"nickname"  defaultValue:@""];
        self.cityCode    = [dic getStringValueForKey:@"district"  defaultValue:@""];
        self.telephone   = [dic getStringValueForKey:@"telephone" defaultValue:@""];
        
        self.locationArray = [dic getObjectValueForKey:@"locationArray" defaultValue:@[]];
        self.starting    = [dic getStringValueForKey:@"starting"    defaultValue:@"Legionarska Bratislava"];
        self.destination = [dic getStringValueForKey:@"destination" defaultValue:@"Levicka ulica 3 Bratislava"];
        self.distance    = [dic getFloatValueForKey:@"distance"     defaultValue:0];
        self.avgConsumption  = [dic getFloatValueForKey:@"avgConsumption" defaultValue:0];
        self.fuelConsumption = [dic getIntValueForKey:@"fuelConsumption" defaultValue:0];
        self.avgSpeed    = [dic getIntValueForKey:@"avgSpeed"  defaultValue:0];
        self.topSpeed    = [dic getIntValueForKey:@"topSpeed"  defaultValue:0];
        self.driveTime   = [dic getIntValueForKey:@"driveTime" defaultValue:0];
        
        self.zipCode    = [dic getStringValueForKey:@"zipCode" defaultValue:@"024"];
        self.inProvince = [dic getStringValueForKey:@"inProvince" defaultValue:@"1"];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder*)coder
{
    if(self = [super init])
    {
        self.userId    = [coder decodeObjectForKey:@"userId"];
        self.headImage = [coder decodeObjectForKey:@"headImage"];
        self.nickName  = [coder decodeObjectForKey:@"nickname"];
        self.gender    = [coder decodeObjectForKey:@"gender"];
        self.cityCode  = [coder decodeObjectForKey:@"district"];
        self.telephone = [coder decodeObjectForKey:@"telephone"];

        self.locationArray   = [coder decodeObjectForKey:@"locationArray"];
        self.starting        = [coder decodeObjectForKey:@"starting"];
        self.destination     = [coder decodeObjectForKey:@"destination"];
        self.distance        = [coder decodeFloatForKey:@"distance"];
        self.avgConsumption  = [coder decodeFloatForKey:@"avgConsumption"];
        self.fuelConsumption = [coder decodeIntForKey:@"fuelConsumption"];
        self.avgSpeed        = [coder decodeIntForKey:@"avgSpeed"];
        self.topSpeed        = [coder decodeIntForKey:@"topSpeed"];
        self.driveTime       = [coder decodeIntForKey:@"driveTime"];
        
        self.zipCode    = [coder decodeObjectForKey:@"zipCode"];
        self.inProvince = [coder decodeObjectForKey:@"inProvince"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_userId    forKey:@"userId"];
    [coder encodeObject:_headImage forKey:@"headImage"];
    [coder encodeObject:_nickName  forKey:@"nickname"];
    [coder encodeObject:_gender    forKey:@"gender"];
    [coder encodeObject:_cityCode  forKey:@"district"];
    [coder encodeObject:_telephone forKey:@"telephone"];
    [coder encodeObject:_district  forKey:@"cityCode"];
    
    [coder encodeObject:_locationArray forKey:@"locationArray"];
    [coder encodeObject:_starting      forKey:@"starting"];
    [coder encodeObject:_destination   forKey:@"destination"];
    [coder encodeFloat:_distance         forKey:@"distance"];
    [coder encodeFloat:_avgConsumption forKey:@"avgConsumption"];
    [coder encodeInt:_fuelConsumption  forKey:@"fuelConsumption"];
    [coder encodeInt:_avgSpeed         forKey:@"avgSpeed"];
    [coder encodeInt:_topSpeed         forKey:@"topSpeed"];
    [coder encodeInt:_driveTime        forKey:@"driveTime"];
    
    [coder encodeObject:_zipCode    forKey:@"zipCode"];
    [coder encodeObject:_inProvince forKey:@"inProvince"];
}

@end
