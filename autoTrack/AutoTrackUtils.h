//
//  AutoTrackUtils.h
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 2017/6/29.
//  Copyright © 2017年 SensorsData. All rights reserved.
//
新增的一条记录 看看行不行
会尽快发货进度符合考试会计
#import <UIKit/UIKit.h>
#import "SALogger.h"

@interface AutoTrackUtils : NSObject

+ (void)trackAppClickWithUITableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

+ (void)trackAppClickWithUICollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

+ (NSString *)contentFromView:(UIView *)rootView;

+ (void)sa_addViewPathProperties:(NSMutableDictionary *)properties withObject:(UIView *)view withViewController:(UIViewController *)viewController;

+ (UIViewController *)currentViewController;
+ (NSString *)getUIViewControllerTitle:(UIViewController *)controller;
@end
