//
//  UIView+Progressive.m
//  HEMS
//  渐进式动画
//  Created by daiyi on 16/7/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "UIView+Progressive.h"
#import <objc/runtime.h>

#define PROGRESSIVE_DEFAULT_DURATION 1.f

// 渐进目的
typedef NS_ENUM(NSInteger, ProgressivePurpose) {
    ProgressivePurposeShow,
    ProgressivePurposeHide,
    ProgressivePurposeUnknow
};

typedef void(^Block)();

static const void *BlockKey = &BlockKey;

@interface UIView ()<CAAnimationDelegate>

@property (nonatomic, copy) Block completeBlock;
/** 动画方向 */
@property (nonatomic, assign) ProgressiveDirection direction;
/** 是否在动画中 */
@property (nonatomic, assign, readwrite, getter = isProgressAnimating) BOOL progressAnimating;
/** 动画执行时间 */
@property (nonatomic, assign) CFTimeInterval duration;

@end

@implementation UIView (Progressive)

- (void)showProgressiveWithDirection:(ProgressiveDirection)direction duration:(NSTimeInterval)duration {
    self.duration = duration;
    [self showProgressiveWithDirection:direction];
}

- (void)showProgressiveWithDirection:(ProgressiveDirection)direction {
    [self doProgressiveAnimateWithDirection:direction complete:nil purpose:ProgressivePurposeShow];
}

- (void)hideProgressiveWithDirection:(ProgressiveDirection)direction complete:(void (^)())completeBlock duration:(NSTimeInterval)duration {
    self.duration = duration;
    [self hideProgressiveWithDirection:direction complete:completeBlock];
}

- (void)hideProgressiveWithDirection:(ProgressiveDirection)direction complete:(void(^)())completeBlock {
    [self doProgressiveAnimateWithDirection:direction complete:completeBlock purpose:ProgressivePurposeHide];
}

#pragma mark - 动画方法
- (void)doProgressiveAnimateWithDirection:(ProgressiveDirection)direction complete:(void(^)())completeBlock purpose:(ProgressivePurpose)purpose {
    if (completeBlock) {
        self.completeBlock = completeBlock;
    }
    
    if (self.duration == 0) {
        self.duration = 1.f;
    }
    self.direction = direction;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIBezierPath *startPath;     // 渐进开始路径
    UIBezierPath *endPath;     // 渐进结束路径
    // 遮罩layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = endPath.CGPath;
    self.layer.mask = shapeLayer;
    
    if (self.direction == ProgressiveDirectionTop
        || self.direction == ProgressiveDirectionVerticalCenter
        || self.direction == ProgressiveDirectionBottom) {
        switch (self.direction) {
            case ProgressiveDirectionTop:
            {
                if (purpose == ProgressivePurposeShow) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, 0)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                } else if (purpose == ProgressivePurposeHide) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, height, width, 0)];
                }
            }
                break;
            case ProgressiveDirectionVerticalCenter:
            {
                if (purpose == ProgressivePurposeShow) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, height * 0.5, width, 0)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                } else if (purpose == ProgressivePurposeHide) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, height * 0.5, width, 0)];
                }
            }
                break;
            case ProgressiveDirectionBottom:
            {
                if (purpose == ProgressivePurposeShow) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, height, width, 0)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                } else if (purpose == ProgressivePurposeHide) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, 0)];
                }
            }
                break;
            default:
                break;
        }
    }else if (self.direction == ProgressiveDirectionLeft
              || self.direction == ProgressiveDirectionHorizontalCenter
              || self.direction == ProgressiveDirectionRight) {
        switch (self.direction) {
            case ProgressiveDirectionLeft:
            {
                if (purpose == ProgressivePurposeShow) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 0, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                } else if (purpose == ProgressivePurposeHide) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(width, 0, 0, height)];
                }
            }
                break;
            case ProgressiveDirectionHorizontalCenter:
            {
                if (purpose == ProgressivePurposeShow) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(width * 0.5, 0, 0, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                } else if (purpose == ProgressivePurposeHide) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(width * 0.5, 0, 0, height)];
                }
            }
                break;
            case ProgressiveDirectionRight:
            {
                if (purpose == ProgressivePurposeShow) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(width, 0, 0, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                } else if (purpose == ProgressivePurposeHide) {
                    startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
                    endPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 0, height)];
                }
            }
                break;
            default:
                break;
        }
    }else if (self.direction == ProgressiveDirectionRound) {
        // 斜边长度
        CGFloat diagonal = hypot(width / 2, height / 2);
        
        if (purpose == ProgressivePurposeShow) {
            startPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:1 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            endPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:diagonal startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        } else if (purpose == ProgressivePurposeHide) {
            startPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:diagonal startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            endPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:1 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        }
    }
    
    shapeLayer.path = endPath.CGPath;
    
    CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    progressAnimation.duration = self.duration;
    progressAnimation.fromValue = (__bridge id _Nullable)(startPath.CGPath);
    progressAnimation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    progressAnimation.delegate = self;
    [progressAnimation setValue:@(purpose) forKeyPath:@"purpose"];
    [shapeLayer addAnimation:progressAnimation forKey:nil];
}

/*! @brief 动画结束处理
 *
 * @param purpose 动画类型
 */
- (void)handleComplete:(ProgressivePurpose)purpose {
    switch (purpose) {
        case ProgressivePurposeShow:
            break;
        case ProgressivePurposeHide:
        {
            if (self.completeBlock) {
                self.completeBlock();
                self.completeBlock = nil;
            }
        }
            break;
        case ProgressivePurposeUnknow:
            break;
        default:
            break;
    }
}

#pragma mark - CAAnimationDelegate代理方法
- (void)animationDidStart:(CAAnimation *)anim {
    self.progressAnimating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.progressAnimating = NO;
    
    [self handleComplete:[[anim valueForKeyPath:@"purpose"] integerValue]];
}


#pragma mark - setter/getter方法
- (ProgressiveDirection)direction {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setDirection:(ProgressiveDirection)direction {
    objc_setAssociatedObject(self, @selector(direction), @(direction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCompleteBlock:(Block)completeBlock {
    objc_setAssociatedObject(self, BlockKey, completeBlock, OBJC_ASSOCIATION_COPY);
}

- (Block)completeBlock {
    return objc_getAssociatedObject(self, BlockKey);
}

- (void)setProgressAnimating:(BOOL)progressAnimating {
    objc_setAssociatedObject(self, @selector(progressAnimating), @(progressAnimating), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isProgressAnimating {
    return [objc_getAssociatedObject(self, @selector(progressAnimating)) boolValue];
}

- (void)setDuration:(CGFloat)duration {
    objc_setAssociatedObject(self, @selector(duration), @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)duration {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

@end
