//
//  AppDelegate.h
//  CloundKit
//
//  Created by LDY on 17/4/11.
//  Copyright © 2017年 LDY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@property(nonatomic,strong) CKRecord*record;


@end

