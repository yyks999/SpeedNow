//
//  NSString+HMString.h
//
//  Created by David Fox on 6/30/12.
//  Copyright (c) 2012 David Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(HMString)
#pragma mark -
#pragma mark App Version
- (NSComparisonResult)versionStringCompare:(NSString*)other;
- (NSComparisonResult)appVersionCompare;
- (NSComparisonResult)bundleVersionCompare;
+ (NSString*)appVersion;

#pragma mark -
#pragma mark String Size
-(CGSize) stringSizeWithFont:(UIFont *) font LimitedWidth:(CGFloat) width;
#pragma mark -
#pragma mark format date


#pragma mark -
#pragma mark String Function
-(NSString *) trimString;
-(NSString *) cleanSpace;

#pragma mark -
#pragma mark Format BSSID
/**
* iOS中提供的BSSID格式为**:**:**...
* 但是它会省略零字符，比如09:a3:...就会写成9:a3
* 此方法为了把省略的零字符补回来
*/
-(NSString *)formatBSSID;


#pragma mark - 字符串的比较
- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options;
- (BOOL)containsString:(NSString *)string;

@end
