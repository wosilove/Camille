//
//  CMLControlHandle.h
//  CamilleTest
//
//  Created by 杨淳引 on 2016/12/19.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat controlHandleHeight;

typedef void (^ControlHandleBlock)();

@interface CMLControlHandleCircleView : UIView

@property (nonatomic, assign) BOOL isClockwiseAnimating;
@property (nonatomic, assign) BOOL isAntiClockwiseAnimating;

+ (CMLControlHandleCircleView *)loadCircleView;
- (void)turnByClockwise;
- (void)turnByAntiClockwise;
- (void)turnFrom:(CGFloat)lastOffsetY to:(CGFloat)currentOffsetY;
- (void)restore;
- (void)stop;

@end

@interface CMLControlHandle : UIView

@property (nonatomic, copy) ControlHandleBlock clickAction;
@property (nonatomic, assign) CGFloat lastOffsetY; //所属scrollView的初始OffsetY
@property (nonatomic, assign) BOOL moveAnimation; //YES：控件右移消失；NO：控件alpha减少消失。默认YES
@property (nonatomic, assign) BOOL slowAnimation; //当moveAnimation为YES时生效，表示是否随着scrollView的拖动慢慢移动，默认为NO
@property (nonatomic, assign) BOOL completeHide; //moveAnimation为YES时，隐藏时是否整体隐藏，默认为NO
@property (nonatomic, assign) BOOL rightViewHidden; //rightView是否隐藏
@property (nonatomic, assign) BOOL isConstantSpeedTurning; //circleView旋转的时候是否匀速，默认为NO

+ (CMLControlHandle *)loadControlHandleAbove:(UIView *)superView;
+ (CMLControlHandle *)loadControlHandleWithY:(CGFloat)y above:(UIView *)superView;

- (void)turnByClockwise;
- (void)turnByAntiClockwise;
- (void)restore;
- (void)stop;

- (void)showWithAnimation:(BOOL)animated;
- (void)hideWithAnimation:(BOOL)animated;

- (void)motionAfterScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)motionAfterScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)motionAfterScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)motionAfterScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
