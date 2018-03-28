//
//  UIImage+category.m
//  iLearning
//
//  Created by 杨翊楷 on 13-8-20.
//  Copyright (c) 2013年 iSoftstone infomation Technology (Group) Co.,Ltd. All rights reserved.
//

#import "UIImage+category.h"

@implementation UIImage (category)


- (UIImage *)imageWithGrayScaleImage:(UIImage *)inputImg
{
    //Creating image rectangle
    //CGRect imageRect = CGRectMake(0, 0, inputImg.size.width / (CGFloat)[inputImg scale], inputImg.size.height / (CGFloat)[inputImg scale]);
    CGRect imageRect = CGRectMake(0, 0, inputImg.size.width, inputImg.size.height);
    
    //Allocating memory for pixels
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    uint32_t *pixels = (uint32_t*)malloc(width * height * sizeof(uint32_t));
    
    //Clearing the memory to preserve any transparency.(Alpha)
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    //Creating a context with RGBA pixels
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    //Drawing the bitmap to the context which will fill the pixels memory
    CGContextDrawImage(context, imageRect, [inputImg CGImage]);
    
    //Indices as ARGB or RGBA
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            uint8_t* rgbaPixel = (uint8_t*)&pixels[y * width + x];
            
            //Calculating the grayScale value
            uint32_t grayPixel = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            //Setting the pixel to gray
            rgbaPixel[RED] = grayPixel;
            rgbaPixel[GREEN] = grayPixel;
            rgbaPixel[BLUE] = grayPixel;
        }
    }
    
    //Creating new CGImage from the context with modified pixels
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    //Releasing resources to free up memory
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    //Creating UIImage for return value
    //UIImage* newUIImage = [UIImage imageWithCGImage:newCGImage scale:(CGFloat)[inputImg scale] orientation:UIImageOrientationUp];
    UIImage* newUIImage = [UIImage imageWithCGImage:newCGImage];
    
    //Releasing the CGImage
    CGImageRelease(newCGImage);
    
    return newUIImage;
}

+ (UIImage *)createImageWithBgColor:(UIColor *)color size:(CGSize)size cornerRadius:(float)corner
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.backgroundColor = color;
    [view.layer setCornerRadius:corner];
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;

}


@end
