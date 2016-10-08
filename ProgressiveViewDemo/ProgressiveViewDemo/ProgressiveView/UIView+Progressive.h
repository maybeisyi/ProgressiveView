//
//  UIView+Progressive.h
//  HEMS
//  渐进式动画
//  Created by daiyi on 16/7/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 动画方向 */
typedef NS_ENUM(NSInteger, ProgressiveDirection) {
    ProgressiveDirectionTop,
    ProgressiveDirectionVerticalCenter,
    ProgressiveDirectionBottom,
    ProgressiveDirectionLeft,
    ProgressiveDirectionHorizontalCenter,
    ProgressiveDirectionRight,
    ProgressiveDirectionRoundSpread,        // 出现动画中使用
    ProgressiveDirectionRoundConstrict      // 消失动画中使用
};

@interface UIView (Progressive)

@property (nonatomic, assign, readonly, getter = isProgressAnimating) BOOL progressAnimating;

/*! @brief 渐进展开动画
 *
 * @param direction 动画方向
 */
- (void)showProgressiveWithDirection:(ProgressiveDirection)direction;

/*! @brief 渐进展开动画
 *
 * @param direction 动画方向
 * @param duration 动画执行时间
 */
- (void)showProgressiveWithDirection:(ProgressiveDirection)direction duration:(NSTimeInterval)duration;

/*! @brief 渐进消失动画
 *
 * @param direction 动画方向
 * @param completeBlock 消失完成后执行操作
 */
- (void)hideProgressiveWithDirection:(ProgressiveDirection)direction complete:(void(^)())completeBlock;

/*! @brief 渐进消失动画
 *
 * @param direction 动画方向
 * @param completeBlock 消失完成后执行操作
 * @param duration 动画执行时间
 */
- (void)hideProgressiveWithDirection:(ProgressiveDirection)direction complete:(void(^)())completeBlock duration:(NSTimeInterval)duration;

@end
