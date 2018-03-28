//
//  PoliceViewController.m
//  CircleTest
//
//  Created by 杨翊楷 on 15/10/4.
//  Copyright © 2015年 杨翊楷. All rights reserved.
//

#import "PoliceViewController.h"
#import "YKSexangleCircleView.h"

@interface PoliceViewController ()

@property (nonatomic, strong) YKSexangleCircleView *circle;

@property (nonatomic, strong) NSArray *policeContents;

@end

@implementation PoliceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.25f green:0.26f blue:0.38f alpha:1.00f];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    _policeContents = @[@"W",@"O",@"R",@"L",@"D",@":-)"];
    
    _circle = [[YKSexangleCircleView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 250) / 2, (SCREEN_HEIGHT - 250) / 2, 250, 250)];
    [_circle setCenterTitle:@"HELLO"];
    [self.view addSubview:_circle];
    
    PoliceViewController *vc = self;
    _circle.buttonClick = ^(YKButton *button, NSInteger index)
    {
        switch (index) {
            case 0:
                [vc.circle hide];
                [vc flipNewAnimation:(UIView *)vc.circle.centerButton type:UIViewAnimationOptionTransitionFlipFromLeft];
                [vc performSelector:@selector(showPolice) withObject:nil afterDelay:1];
                
                break;
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:

                break;
                
            default:
                break;
        }
    };
    
    [self performSelector:@selector(showPolice) withObject:nil afterDelay:1];

    
    UISwipeGestureRecognizer *backGuest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    backGuest.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:backGuest];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)showPolice
{
    [_circle showWithContents:_policeContents];
}

-(void)flipNewAnimation:(UIView *)view type:(int)type
{
    [UIView transitionWithView:view duration:0.8 options:type animations:^{
        
    } completion:^(BOOL finished) {
        if(finished)
        {
            
        }
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
