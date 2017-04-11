//
//  ViewController.m
//  CloundKit
//
//  Created by LDY on 17/4/11.
//  Copyright © 2017年 LDY. All rights reserved.
//

#import "ViewController.h"
#import <CloudKit/CloudKit.h>
#import "AppDelegate.h"
@interface ViewController ()

@property(nonatomic,strong)CKContainer *container;

@property(nonatomic,copy)NSString *recordName;

@end

#ifndef __OPTIMIZE__
# define NSLog(...) NSLog(__VA_ARGS__)
#else
# define NSLog(...)
#endif

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//     [self accountStatusCheck];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(checkPublicDatas)];
    
    [self qureyPublicDatas];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- 用户管理
-(void)accountStatusCheck{
    //cloud账户状态检测
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        switch (accountStatus) {
            case CKAccountStatusCouldNotDetermine:
                NSLog(@"CKAccountStatusCouldNotDetermine");
                break;
            case CKAccountStatusAvailable:
                [self statusPermission];
                NSLog(@"CKAccountStatusAvailable");
                break;
            case CKAccountStatusRestricted:
                NSLog(@"CKAccountStatusRestricted");
                break;
            case CKAccountStatusNoAccount:
                NSLog(@"CKAccountStatusNoAccount");//一定要打开iCloud Drive否则CKAccountStatusNoAccount
                break;
            default:
                break;
        }
        
        if (error) {
            NSLog(@"accountStatus error = %@",error);
        }
    }];
    
    
    
}
//检查授权
-(void)statusPermission{
    [[CKContainer defaultContainer] statusForApplicationPermission:CKApplicationPermissionUserDiscoverability  completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError * _Nullable error) {
        switch (applicationPermissionStatus) {
            case CKApplicationPermissionStatusInitialState:
                NSLog(@"CKApplicationPermissionStatusInitialState");
                [self requestPermission];
                break;
            case CKApplicationPermissionStatusCouldNotComplete:
                NSLog(@"CKApplicationPermissionStatusCouldNotComplete");
                break;
            case CKApplicationPermissionStatusDenied:
                NSLog(@"CKApplicationPermissionStatusDenied");
                break;
            case CKApplicationPermissionStatusGranted:
                NSLog(@"CKApplicationPermissionStatusGranted");
                [self fetchRecordID];
                break;
            default:
                break;
        }
        if (error) {//Request failed with http status code 503 服务器问题，不必惊慌
            NSLog(@"statusForApplicationPermission error %@",error);
        }
    }];

}
//请求授权
-(void)requestPermission{
    [[CKContainer defaultContainer] requestApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError * _Nullable error) {
        switch (applicationPermissionStatus) {
            case CKApplicationPermissionStatusInitialState:
                NSLog(@"CKApplicationPermissionStatusInitialState");
                break;
            case CKApplicationPermissionStatusCouldNotComplete:
                NSLog(@"CKApplicationPermissionStatusCouldNotComplete");
                break;
            case CKApplicationPermissionStatusDenied:
                NSLog(@"CKApplicationPermissionStatusDenied");
                break;
            case CKApplicationPermissionStatusGranted:
                NSLog(@"CKApplicationPermissionStatusGranted");
                [self fetchRecordID];
                break;
            default:
                break;
        }
        
        if (error) {
            NSLog(@"requestApplicationPermission = error = %@",error);
        }
    }];
    
}
//获取用户RecordID
-(void)fetchRecordID{
    [[CKContainer defaultContainer]fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fetchUserRecordID error =%@",error);
        }else{
            NSLog(@"recordID.recordName = %@ recordID.zoneID = %@",recordID.recordName,recordID.zoneID);
            self.recordName = recordID.recordName;
            [self discoverAllUserContactInfo:recordID];
        }
    }];
}
//搜索联系人信息
-(void)discoverAllUserContactInfo:(CKRecordID *)recordID{
    [[CKContainer defaultContainer]discoverAllIdentitiesWithCompletionHandler:^(NSArray<CKUserIdentity *> * _Nullable userIdentities, NSError * _Nullable error) {
        NSLog(@"discoverAllIdentities userIdentities = %@",userIdentities);
        if (error) {
            NSLog(@"discoverAllIdentities error = %@",error);
        }
    }];
}
#pragma mark- 访问数据
//公共数据
-(void)checkPublicDatas{
    //根据CKRecordID 查询CKRecord
    CKDatabase *publiceBase = [[CKContainer defaultContainer]publicCloudDatabase];
    CKRecordID *recordID = [[CKRecordID alloc]initWithRecordName:self.recordName];
    [publiceBase fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (error) {
            NSLog(@"fetchRecordWithID error = %@",error);
        }else{
            NSLog(@"fetchRecordWithID record = %@",record);
            
            AppDelegate *delegete = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegete setRecord:record];
        }
    }];
}

-(void)qureyPublicDatas{
    CKDatabase *publiceBase = [[CKContainer defaultContainer]publicCloudDatabase];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuery * query = [[CKQuery alloc]initWithRecordType:@"Race" predicate:predicate];
    [publiceBase performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (error) {
            NSLog(@"performQuery error = %@",error);
        }else{
            NSLog(@"performQuery results = %@",results);
        }
    }];
}

-(void)createDates{
    CKDatabase *publiceBase = [[CKContainer defaultContainer]publicCloudDatabase];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CKRecord *record = delegate.record;
    
//    CKReference ?
    [publiceBase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        
    }];
}
#pragma mark- 更新数据




#pragma mark- specify coustom container
/*
 //    self.container = [CKContainer containerWithIdentifier:@"iCloud.com.QianHaiLDY.zucheStaff"];
 
 [self.container statusForApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError * _Nullable error) {
 switch (applicationPermissionStatus) {
 case CKApplicationPermissionStatusInitialState:
 NSLog(@"CKApplicationPermissionStatusInitialState");
 break;
 case CKApplicationPermissionStatusCouldNotComplete:
 NSLog(@"CKApplicationPermissionStatusCouldNotComplete");
 break;
 case CKApplicationPermissionStatusDenied:
 NSLog(@"CKApplicationPermissionStatusDenied");
 break;
 case CKApplicationPermissionStatusGranted:
 NSLog(@"CKApplicationPermissionStatusGranted");
 break;
 default:
 break;
 }
 if (error) {
 NSLog(@"statusForApplicationPermission error %@",error);
 }
 
 }];

 
 [self.container requestApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError * _Nullable error) {
 switch (applicationPermissionStatus) {
 case CKApplicationPermissionStatusInitialState:
 NSLog(@"CKApplicationPermissionStatusInitialState");
 break;
 case CKApplicationPermissionStatusCouldNotComplete:
 NSLog(@"CKApplicationPermissionStatusCouldNotComplete");
 break;
 case CKApplicationPermissionStatusDenied:
 NSLog(@"CKApplicationPermissionStatusDenied");
 break;
 case CKApplicationPermissionStatusGranted:
 NSLog(@"CKApplicationPermissionStatusGranted");
 break;
 default:
 break;
 }
 
 }];

 
 */
@end
