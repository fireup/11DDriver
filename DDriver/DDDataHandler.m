//
//  DDDataHandler.m
//  DDriver
//
//  Created by ZBN on 14-7-31.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDDataHandler.h"

@implementation DDDataHandler

@synthesize login, phoneNO, sessionID, defaultLoc, title, emergency;

+ (NSDictionary *)convertItemToString:(NSDictionary *)dict
{
    NSMutableDictionary *aDict = [dict mutableCopy];
    for (NSString *aKey in [aDict allKeys]) {
        if ([aDict[aKey] isKindOfClass:[NSDictionary class]]) {
            [DDDataHandler convertItemToString:aDict[aKey]];
            
        } else if(![aDict[aKey] isKindOfClass:[NSString class]]) {
            
            if ([aDict[aKey] isKindOfClass:[NSNull class]]) {
                aDict[aKey] = @"";
            } else {
                NSString *str = [aDict[aKey] stringValue];
                [aDict setObject:str forKey:aKey];
            }
        }
    }
    return [aDict copy];
}


+ (void)networkAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络连接失败" message:@"请确认网络连接通畅" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

+ (void)resultErrorAlert:(NSString *)errorMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发生错误" message: errorMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

+ (void)blankTitleAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (BOOL)isLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
}

- (void)setLogin:(BOOL)loginPassed
{
    [[NSUserDefaults standardUserDefaults] setBool:loginPassed forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)phoneNO
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"phoneNO"];
}

- (void)setPhoneNO:(NSString *)phoneNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"phoneNO"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sessionID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"sessionID"] ? [[NSUserDefaults standardUserDefaults] stringForKey:@"sessionID"] : @"0";
}

- (void)setSessionID:(NSString *)sessionid
{
    [[NSUserDefaults standardUserDefaults] setObject:sessionid forKey:@"sessionID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)defaultLoc
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"defaultLoc"];
}

- (void) setDefaultLoc:(NSDictionary *)defaultloc
{
    [[NSUserDefaults standardUserDefaults] setObject:defaultloc forKey:@"defaultLoc"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)title
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"title"];
}
- (void)setTitle:(NSString *)theTitle
{
    [[NSUserDefaults standardUserDefaults] setObject:theTitle forKey:@"title"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)emergency
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"emergency"];
}
- (void)setEmergency:(NSString *)emergencyNO
{
    [[NSUserDefaults standardUserDefaults] setObject:emergencyNO forKey:@"emergency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)appPlatform
{
    return [UIDevice currentDevice].model;
}

- (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


- (DDLocHandler *)locHandler
{
    if (!_locHandler) {
        _locHandler = [[DDLocHandler alloc] init];
    }
    return _locHandler;
}



#pragma mark - init

+ (instancetype)sharedData
{
    static DDDataHandler *sharedData = nil;
    if (!sharedData) {
        sharedData = [[self alloc] initPrivate];
    }
    return sharedData;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"singleton" reason:@"use [DDDataHandler sharedData]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    return self;
}

@end
