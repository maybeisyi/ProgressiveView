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

typedef NS_ENUM(NSInteger, ProgressivePurpose) {
    ProgressivePurposeShow,
    ProgressivePurposeHide,
    ProgressivePurposeUnknow
};

typedef void(^Block)();

static CGFloat staticHeight = 0;
static const void *CADisplayLinkKey = &CADisplayLinkKey;
static const void *BlockKey = &BlockKey;

@interface UIView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, copy) Block completeBlock;
/** 动画方向 */
@property (nonatomic, assign) ProgressiveDirection direction;
/** 是否在动画中 */
@property (nonatomic, assign, readwrite, getter = isProgressAnimating) BOOL progressAnimating;
/** 动画执行时间 */
@property (nonatomic, assign) CGFloat duration;

@end

@implementation UIView (Progressive)

- (void)showProgressiveWithDirection:(ProgressiveDirection)direction duration:(NSTimeInterval)duration {
    self.duration = duration;
    [self showProgressiveWithDirection:direction];
}

- (void)showProgressiveWithDirection:(ProgressiveDirection)direction {
    [self prepareForAnimation:direction];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(showProgressiveAnimate)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)hideProgressiveWithDirection:(ProgressiveDirection)direction complete:(void (^)())completeBlock duration:(NSTimeInterval)duration {
    self.duration = duration;
    [self hideProgressiveWithDirection:direction complete:completeBlock];
}

- (void)hideProgressiveWithDirection:(ProgressiveDirection)direction complete:(void(^)())completeBlock {
    if (completeBlock) {
        self.completeBlock = completeBlock;
    }
    [self prepareForAnimation:direction];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(hideProgressiveAnimate)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

/*! @brief 动画前准备工作
 *
 * @param direction 方向
 */
- (void)prepareForAnimation:(ProgressiveDirection)direction {
    self.direction = direction;
    staticHeight = 0;
    self.progressAnimating = YES;
}

/*! @brief 动画结束处理
 *
 * @param purpose 动画类型
 */
- (void)handleComplete:(ProgressivePurpose)purpose {
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.progressAnimating = NO;
    self.duration = 0;
    
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

#pragma mark - 动画过程
- (void)hideProgressiveAnimate {
    self.hidden = NO;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat numberOfFPS = (60 * (self.duration > 0.01 ? self.duration : PROGRESSIVE_DEFAULT_DURATION));
    UIBezierPath *bezierPath;
    
    if (self.direction == ProgressiveDirectionTop
        || self.direction == ProgressiveDirectionVerticalCenter
        || self.direction == ProgressiveDirectionBottom) {
        staticHeight += height / numberOfFPS;
        switch (self.direction) {
            case ProgressiveDirectionTop:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, staticHeight, width, height - staticHeight)];
            }
                break;
            case ProgressiveDirectionVerticalCenter:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height / 2 - staticHeight / 2)];
                [bezierPath moveToPoint:(CGPoint){0, height / 2 + staticHeight / 2}];
                [bezierPath addLineToPoint:(CGPoint){width, height / 2 + staticHeight / 2}];
                [bezierPath addLineToPoint:(CGPoint){width, height}];
                [bezierPath addLineToPoint:(CGPoint){0, height}];
                [bezierPath closePath];
            }
                break;
            case ProgressiveDirectionBottom:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height - staticHeight)];
            }
                break;
            default:
                break;
        }
        
        if (staticHeight > height) {
            [self handleComplete:ProgressivePurposeHide];
        }
    }else if (self.direction == ProgressiveDirectionLeft
              || self.direction == ProgressiveDirectionHorizontalCenter
              || self.direction == ProgressiveDirectionRight) {
        staticHeight += width / numberOfFPS;
        switch (self.direction) {
            case ProgressiveDirectionLeft:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(staticHeight, 0, width - staticHeight, height)];
            }
                break;
            case ProgressiveDirectionHorizontalCenter:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width / 2 - staticHeight / 2, height)];
                [bezierPath moveToPoint:(CGPoint){width / 2 + staticHeight / 2, 0}];
                [bezierPath addLineToPoint:(CGPoint){width / 2 + staticHeight / 2, height}];
                [bezierPath addLineToPoint:(CGPoint){width, height}];
                [bezierPath addLineToPoint:(CGPoint){width, 0}];
                [bezierPath closePath];
            }
                break;
            case ProgressiveDirectionRight:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width - staticHeight, height)];
            }
                break;
            default:
                break;
        }
        
        if (staticHeight > width) {
            [self handleComplete:ProgressivePurposeHide];
        }
    }else if (self.direction == ProgressiveDirectionRoundConstrict) {
        // 斜边长度
        CGFloat diagonal = hypot(width / 2, height / 2);
        staticHeight += diagonal / numberOfFPS;
        bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:MAX(0, diagonal - staticHeight) startAngle:0 endAngle:M_PI * 2 clockwise:1];
        
        if (staticHeight > diagonal) {
            [self handleComplete:ProgressivePurposeHide];
        }
    }
    
    if (bezierPath) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bezierPath.CGPath;
        self.layer.mask = shapeLayer;
    }
}

- (void)showProgressiveAnimate {
    self.hidden = NO;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat numberOfFPS = (60 * (self.duration > 0.01 ? self.duration : PROGRESSIVE_DEFAULT_DURATION));
    UIBezierPath *bezierPath;
    
    // 方向
    if (self.direction == ProgressiveDirectionTop
        || self.direction == ProgressiveDirectionVerticalCenter
        || self.direction == ProgressiveDirectionBottom) {
        staticHeight += height / numberOfFPS;
        switch (self.direction) {
            case ProgressiveDirectionTop:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, staticHeight)];
            }
                break;
            case ProgressiveDirectionVerticalCenter:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, height / 2 - staticHeight / 2, width, staticHeight)];
            }
                break;
            case ProgressiveDirectionBottom:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, height - staticHeight, width, staticHeight)];
            }
                break;
            default:
                break;
        }
        
        if (staticHeight > height) {
            [self handleComplete:ProgressivePurposeShow];
        }
    }else if (self.direction == ProgressiveDirectionLeft
              || self.direction == ProgressiveDirectionHorizontalCenter
              || self.direction == ProgressiveDirectionRight) {
        staticHeight += width / numberOfFPS;
        switch (self.direction) {
            case ProgressiveDirectionLeft:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, staticHeight, height)];
            }
                break;
            case ProgressiveDirectionHorizontalCenter:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(width / 2 - staticHeight / 2, 0, staticHeight, height)];
            }
                break;
            case ProgressiveDirectionRight:
            {
                bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(width - staticHeight, 0, staticHeight, height)];
            }
                break;
            default:
                break;
        }
        
        if (staticHeight > width) {
            [self handleComplete:ProgressivePurposeShow];
        }
    }else if (self.direction == ProgressiveDirectionRoundSpread) {
        // 斜边长度
        CGFloat diagonal = hypot(width / 2, height / 2);
        staticHeight += diagonal / numberOfFPS;
        
        bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:staticHeight startAngle:0 endAngle:M_PI * 2 clockwise:1];
        
        if (staticHeight > diagonal) {
            [self handleComplete:ProgressivePurposeShow];
        }
    }
    
    if (bezierPath) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bezierPath.CGPath;
        self.layer.mask = shapeLayer;
    }
}

#pragma mark - setter/getter方法
- (CADisplayLink *)displayLink {
    return objc_getAssociatedObject(self, CADisplayLinkKey);
}

- (void)setDisplayLink:(CADisplayLink *)displayLink {
    objc_setAssociatedObject(self, CADisplayLinkKey, displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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
