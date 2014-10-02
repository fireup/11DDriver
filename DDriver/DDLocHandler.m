//
//  DDLocHandler.m
//  DDriver11
//
//  Created by ZBN on 14-7-26.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDLocHandler.h"
#import "DDDataHandler.h"

@interface DDLocHandler () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate> {
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_search;
}

@end

@implementation DDLocHandler

- (void)updateCurrentLocationAndAddress
{
    NSLog(@"_locService Start");
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (!_locService) {
        _locService = [[BMKLocationService alloc] init];
    }
    
    if (!_locService.delegate) {
        _locService.delegate = self;
        self.active = YES;
        [_locService startUserLocationService];
    }
}

- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
//    _CLManager = nil;
    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
    NSLog(@"getlocation: %f, %f", coordinate.latitude, coordinate.longitude);
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    [DDDataHandler sharedData].userLocation = userLocation;
    [self updateCurrentAddressWithLocation:userLocation.location];

//    if (![DDDataHandler sharedData].currentAddress) {
//        [self updateCurrentAddressWithLocation:userLocation.location];
//    } else {
//        CLLocationDistance distance = [[DDDataHandler sharedData].currentLocation distanceFromLocation:userLocation.location];
//        if (distance > 50.0) {
//            [self updateCurrentAddressWithLocation:userLocation.location];
//        } else {
//            self.active = NO;
//        }
//    }
//    NSLog(@"%@: %d", NSStringFromSelector(_cmd),self.active);

}

- (void)updateCurrentAddressWithLocation:(CLLocation *)location
{
    CLLocationCoordinate2D coordinate = location.coordinate;
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    option.reverseGeoPoint = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    _search = [[BMKGeoCodeSearch alloc] init];
    _search.delegate = self;
    [_search reverseGeoCode:option];
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    self.active = NO;
    _search.delegate = nil;
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSString *city = result.addressDetail.city;
        if ([VALIDCITY rangeOfString:city].location == NSNotFound) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoValidCity" object:self];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您所在的城市暂未开通代驾业务" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            CLLocationCoordinate2D coordinate = result.location;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            [DDDataHandler sharedData].currentLocation = location;
            [DDDataHandler sharedData].currentAddress = result.address;
            [DDDataHandler sharedData].city = city;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentAddressUpdated" object:self];
        }
    } else {
        [DDDataHandler blankTitleAlert:[NSString stringWithFormat:@"获取地址失败，错误代码＝%d", error]];
    }
}

- (void)convertAddressToLocation:(NSString *)address city:(NSString *)city
{
    if ([VALIDCITY rangeOfString:city].location == NSNotFound) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NoValidCity" object:self];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您所在的城市暂未开通代驾业务" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        BMKGeoCodeSearchOption *option = [[BMKGeoCodeSearchOption alloc] init];
        option.address = address;
        option.city = city;
        _search = [[BMKGeoCodeSearch alloc] init];
        _search.delegate = self;
        [_search geoCode:option];
    }
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    _search.delegate = nil;

    if (error == BMK_SEARCH_NO_ERROR) {
        CLLocationCoordinate2D coordinate = result.location;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [DDDataHandler sharedData].customLocation = location;
        [DDDataHandler sharedData].customAddress = result.address;
        [self.delegate locHandlerDidFinishConvertAddress:result.address];

    } else {
        [self.delegate locHandlerDidFailConvertAddress:result.address];
        [DDDataHandler blankTitleAlert:[NSString stringWithFormat:@"获取坐标失败，错误代码＝%d", error]];
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
//    _CLManager = nil;
    NSLog(@"_locService Failed");
    self.active = NO;
    [DDDataHandler sharedData].currentLocation = nil;
    [DDDataHandler sharedData].currentAddress = nil;
    [DDDataHandler sharedData].city = nil;
    _locService.delegate = nil;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLocatingFailed" object:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error.code == 0) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"无法定位"
                                                             message:@"无法获取当前位置，请稍后再试"
                                                            delegate:nil
                                                   cancelButtonTitle:@"确认"
                                                   otherButtonTitles:nil, nil];
        [errorAlert show];
    } else if (error.code == 1) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"无法定位"
                                                             message:@"定位功能被禁用"
                                                            delegate:nil
                                                   cancelButtonTitle:@"确认"
                                                   otherButtonTitles:nil, nil];
        [errorAlert show];
    }
}

+ (instancetype)sharedLocater
{
    static DDLocHandler *sharedLocater = nil;
    if (!sharedLocater) {
        sharedLocater = [[self alloc] initPrivate];
    }
    return sharedLocater;
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

- (void)dealloc
{
    NSLog(@"lochandler dealloc");
}

@end
