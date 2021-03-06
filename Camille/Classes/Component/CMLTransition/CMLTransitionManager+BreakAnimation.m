//
//  CMLTransitionManager+BreakAnimation.m
//  Camille
//
//  Created by 杨淳引 on 2017/1/23.
//  Copyright © 2017年 shayneyeorg. All rights reserved.
//

#import "CMLTransitionManager+BreakAnimation.h"
#import "CMLTransitionManager+CommonMethods.h"

@implementation CMLTransitionManager (BreakAnimation)

- (void)breakOpenWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containView = [transitionContext containerView];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGRect rect0 = CGRectMake(0 , 0 , screenWidth, screenHeight/2);
    CGRect rect1 = CGRectMake(0 , screenHeight/2 , screenWidth, screenHeight/2);
    
    UIImage *image0 = [self imageFromView:fromVC.view atFrame:rect0];
    UIImage *image1 = [self imageFromView:fromVC.view atFrame:rect1];
    
    UIImageView *imgView0 = [[UIImageView alloc] initWithImage:image0];
    UIImageView *imgView1 = [[UIImageView alloc] initWithImage:image1];
    
    [containView addSubview:fromVC.view];
    [containView addSubview:toVC.view];
    [containView addSubview:imgView0];
    [containView addSubview:imgView1];
    
    [UIView animateWithDuration:self.transitionTime animations:^{
        imgView0.layer.transform = CATransform3DMakeTranslation(0, -screenHeight/2, 0);
        imgView1.layer.transform = CATransform3DMakeTranslation(0, screenHeight/2, 0);
        
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
            [imgView0 removeFromSuperview];
            [imgView1 removeFromSuperview];
            
        } else {
            [transitionContext completeTransition:YES];
            [imgView0 removeFromSuperview];
            [imgView1 removeFromSuperview];
        }
    }];
}

- (void)breakCloseWithTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containView = [transitionContext containerView];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGRect rect0 = CGRectMake(0 , 0 , screenWidth, screenHeight/2);
    CGRect rect1 = CGRectMake(0 , screenHeight/2 , screenWidth, screenHeight/2);
    
    UIImage *image0 = [self imageFromView:toVC.view atFrame:rect0];
    UIImage *image1 = [self imageFromView:toVC.view atFrame:rect1];
    
    UIImageView *imgView0 = [[UIImageView alloc] initWithImage:image0];
    UIImageView *imgView1 = [[UIImageView alloc] initWithImage:image1];
    
    [containView addSubview:fromVC.view];
    [containView addSubview:toVC.view];
    [containView addSubview:imgView0];
    [containView addSubview:imgView1];
    
    toVC.view.hidden = YES;
    imgView0.layer.transform = CATransform3DMakeTranslation(0, -screenHeight/2, 0);
    imgView1.layer.transform = CATransform3DMakeTranslation(0, screenHeight/2, 0);
    
    [UIView animateWithDuration:self.transitionTime animations:^{
        imgView0.layer.transform = CATransform3DIdentity;
        imgView1.layer.transform = CATransform3DIdentity;
        
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
            
        } else {
            [transitionContext completeTransition:YES];
        }
        toVC.view.hidden = NO;
        [imgView0 removeFromSuperview];
        [imgView1 removeFromSuperview];
    }];
}

@end
