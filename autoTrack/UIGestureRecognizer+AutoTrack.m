//
//  UIGestureRecognizer+AutoStatistic.m
//  AutoStatistic
//
//  Created by IOS01 on 2018/5/29.
//  Copyright © 2018年 IOS01. All rights reserved.
//

#import "UIGestureRecognizer+AutoTrack.h"
#import "SASwizzle.h"
#import "SALogger.h"
#import <objc/runtime.h>
#import "AutoTrackUtils.h"
#import "UIView+AutoStatistic.h"

//static NSMutableDictionary
@implementation UIGestureRecognizer (AutoTrack)

//+(void)load
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        @try {
//            NSError *error = NULL;
//            [UIGestureRecognizer sa_swizzleMethod:@selector(initWithTarget:action:) withMethod:@selector(dt_initWithTarget:action:) error:&error];
//            if (error) {
//                SAError(@"Failed to swizzle sendAction: on UIApplication. Details: %@", error);
//                error = NULL;
//            }
//        } @catch (NSException *exception) {
//            SAError(@"%@ error: %@", self, exception);
//        }
//    });
//}


-(instancetype)dt_initWithTarget:(id)target action:(SEL)action
{
    if (target)
    {
//        NSString *targetClassName = NSStringFromClass([target class]);
        NSBundle *bundle = [NSBundle bundleForClass:[target class]];
        if (bundle == [NSBundle mainBundle]) {
            NSLog(@"自定义的类");
        } else {
            NSLog(@"系统的类");
        }
        if (bundle == [NSBundle mainBundle]) {
            @try {
                //            Class aClass = objc_getClass("UIWebBrowserView");
                SEL sel = @selector(dt_hook_gestureRecognizerAction:);
                // 为UIWebBrowserView增加函数
                class_addMethod([target class], sel, class_getMethodImplementation([self class], sel), "v@:@");
                NSError *error = NULL;
                [[target class] sa_swizzleMethod:action withMethod:sel error:&error];
                if (error) {
                    SAError(@"Failed to swizzle sendAction: on UIApplication. Details: %@", error);
                    error = NULL;
                }
            } @catch (NSException *exception) {
                SAError(@"%@ error: %@", self, exception);
            }
        }
    }
    id gestureRecognizer = [self dt_initWithTarget:target action:action];
    return gestureRecognizer;
}

-(void)dt_addTarget:(id)target action:(SEL)action
{
    
}

-(void)dt_hook_gestureRecognizerAction:(id)gestur
{
    UIGestureRecognizer *gesture = gestur;
    UIView *view = gesture.view;
    if (view){
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        
        UIViewController *viewController = [view viewController];
        
        if (viewController == nil ||
            [@"UINavigationController" isEqualToString:NSStringFromClass([viewController class])]) {
            viewController = [AutoTrackUtils currentViewController];
        }
        if (viewController != nil) {
            //获取 Controller 名称($screen_name)
            NSString *screenName = NSStringFromClass([viewController class]);
            [properties setValue:screenName forKey:@"$screen_name"];
            
            NSString *controllerTitle = viewController.navigationItem.title;
            if (controllerTitle != nil) {
                [properties setValue:viewController.navigationItem.title forKey:@"$title"];
            }
            //再获取 controller.navigationItem.titleView, 并且优先级比较高
            NSString *elementContent = [AutoTrackUtils getUIViewControllerTitle:viewController];
            if (elementContent != nil && [elementContent length] > 0) {
                elementContent = [elementContent substringWithRange:NSMakeRange(0,[elementContent length] - 1)];
                [properties setValue:elementContent forKey:@"$title"];
            }
        }
        [AutoTrackUtils sa_addViewPathProperties:properties withObject:view withViewController:viewController];
        //View Properties
        NSDictionary* propDict = view.sensorsAnalyticsViewProperties;
        if (propDict != nil) {
            [properties addEntriesFromDictionary:propDict];
        }
        [properties setValue:@"gestureRecognizer" forKey:@"$interactionType"];
        SALog(@"%@",properties);
//        SADebug(@"nnnnnnnnn");
    }
    [self dt_hook_gestureRecognizerAction:gestur];
}
@end
