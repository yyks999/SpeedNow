//
//  VideoViewController.m
//  CircleTest
//
//  Created by 杨翊楷 on 15/10/4.
//  Copyright © 2015年 杨翊楷. All rights reserved.
//

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoViewController ()
{
    NSMutableArray *items;
    AVQueuePlayer *player;
}

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self backGroundAnimation];
    
    [self performSelector:@selector(back) withObject:nil afterDelay:36.5];
    
    UISwipeGestureRecognizer *backGuest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    backGuest.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:backGuest];
}

#pragma mark -
#pragma mark - 背景视频

//背景视频
-(void)backGroundAnimation
{
    NSString *moviePath1 = [[NSBundle mainBundle] pathForResource:@"part1" ofType:@"mp4"];
    
    AVPlayerItem *item1 = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:moviePath1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemAlive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    items = [NSMutableArray arrayWithObjects:item1, nil];
    player = [[AVQueuePlayer alloc]initWithItems:items];
    [player play];
//    [self performSelector:@selector(playerItemDidReachEnd:) withObject:nil afterDelay:11];
    // Create and configure AVPlayerLayer
    AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];

    playerLayer.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
    
    //playerLayer.position = CGPointMake(self.view.frame.size.width/2-10, self.view.frame.size.height/2);
    [self.view.layer insertSublayer:playerLayer atIndex:1];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* [[NSNotificationCenter defaultCenter] removeObserver:self
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:[player currentItem]];*/
    //[YYAnimation fadeAnimation:self.view];
    
    //NSLog(@"1---%@",player.items);
    AVPlayerItem *item = player.currentItem;
    //    [player removeItem:item];
    //    NSLog(@"2---%@",player.items);
    //    [player insertItem:item afterItem:[player.items objectAtIndex:0]];
    //    NSLog(@"3---%@",player.items);
    
    
    //NSLog(@"welcome to helloworld i am dj , %f",item.currentTime.value*1.0000/item.currentTime.timescale);
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    //    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>线程2号");
    CMTime time = item.currentTime;
    time.value=1;
    time.timescale = 90000;
    [item seekToTime:time];
    //});
    
    //NSLog(@"~~~welcome to helloworld i am dj , %f",item.currentTime.value*1.0000/item.currentTime.timescale);
    
    [self performSelector:@selector(playerItemDidReachEnd:) withObject:nil afterDelay:11];
    
}

-(void)systemAlive
{
    [player play];
}

- (void)back
{
    [player pause];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
