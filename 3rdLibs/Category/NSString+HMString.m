//
//  NSString+HMString.m
//
//  Created by David Fox on 6/30/12.
//  Copyright (c) 2012 David Gao. All rights reserved.
//

#import "NSString+HMString.h"

@implementation NSString(HMString)
- (NSComparisonResult)versionStringCompare:(NSString *)other{
    NSMutableArray* oneComponents = [[self componentsSeparatedByString:@"."] mutableCopy];
    NSMutableArray* twoComponents = [[other componentsSeparatedByString:@"."] mutableCopy];
    NSInteger maxCount = MAX(oneComponents.count, twoComponents.count);
    for(int i=0;i<maxCount;i++)
    {
        if(i>=oneComponents.count)
        {
            [oneComponents addObject:@"0"];
        }
        if(i>=twoComponents.count)
        {
            [twoComponents addObject:@"0"];
        }
        NSString* onePart = [oneComponents objectAtIndex:i];
        NSString* twoPart = [twoComponents objectAtIndex:i];
        NSComparisonResult mainDiff;
        if ((mainDiff = [onePart compare:twoPart]) != NSOrderedSame) {
            return mainDiff;
        }
    }
    return NSOrderedSame;
}
-(NSComparisonResult)bundleVersionCompare{
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [self versionStringCompare:appVersion];
}
-(NSComparisonResult)appVersionCompare{
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [self versionStringCompare:appVersion];
}
+ (NSString*)appVersion{
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

#pragma mark -
#pragma mark String Size
-(CGSize) stringSizeWithFont:(UIFont *) font LimitedWidth:(CGFloat) width{
//    CGSize contentSize = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGSize contentSize = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return contentSize;
}

#pragma mark -
#pragma mark String Function
-(NSString *) trimString
{
    NSString *cleanString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return cleanString;
}
-(NSString *)cleanSpace
{
    NSString *result = @"";
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];

    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    result = [filteredArray componentsJoinedByString:@""];
    return result;
}

#pragma mark -
#pragma mark Format BSSID
/**
* iOS中提供的BSSID格式为**:**:**...
* 但是它会省略零字符，比如09:a3:...就会写成9:a3
* 此方法为了把省略的零字符补回来
*/
-(NSString *)formatBSSID
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *splitArray = [self componentsSeparatedByString:@":"];
    for(NSString *sub in splitArray){
       if(sub.length == 1){
            NSString *newSub = [NSString stringWithFormat:@"0%@",sub];
           [newArray addObject:newSub];
       } else{
           [newArray addObject:sub];
       }
    }
    NSString *formatString = [newArray componentsJoinedByString:@"-"];
    return formatString;
}




- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string {
    return [self containsString:string options:0];
}

@end
