# ProgressiveView
渐进式视图动画

* 一行代码即可使用

```
[_imageView showProgressiveWithDirection:ProgressiveDirectionTop];
```
and
```
[_imageView hideProgressiveWithDirection:ProgressiveDirectionBottom complete:^{
        NSLog(@"动画完成");
        [_imageView removeFromSuperview];
    }];
```
