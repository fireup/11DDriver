//
//  DDSetDefaultLocViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-30.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDSetDefaultLocViewController.h"
#import <BMapKit.h>
#import "DDPinAnnotation_DefaultLoc.h"
#import "DDLocHandler.h"
#import "DDDataHandler.h"



@interface DDSetDefaultLocViewController () <BMKMapViewDelegate, BMKGeoCodeSearchDelegate> {
    BMKMapView *_mapView;
    BMKGeoCodeSearch *_search;
}

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *completeButton;

@end

@implementation DDSetDefaultLocViewController




- (void)locateUser
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([DDDataHandler sharedData].userLocation) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [_mapView updateLocationData:[DDDataHandler sharedData].userLocation];
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance([DDDataHandler sharedData].userLocation.location.coordinate, 1500, 1500);
        [_mapView setRegion:region animated:YES];
        
    } else if (![DDDataHandler sharedData].userLocation) {
        
        [[DDLocHandler sharedLocater] updateCurrentLocationAndAddress];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateUser) name:@"CurrentAddressUpdated" object:nil];
    }
}

- (IBAction)completeButtonTapped:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//删除地图上手动选择的pin
- (void)clearCustomLocation
{
    [self.defaultLoc removeAllObjects];
    [self.delegate didSetDefaultLoc:self.defaultLoc];
    
    for (id anno in _mapView.annotations) {
        if ([anno isKindOfClass:[DDPinAnnotation_DefaultLoc class]]) {
            [_mapView removeAnnotation:anno];
        }
    }
    ((UIBarButtonItem *)[self.toolbar.items lastObject]).enabled = NO;
}

//长按放置图钉
- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
{
    self.defaultLoc[@"latitude"] = [NSString stringWithFormat:@"%f", coordinate.latitude];
    self.defaultLoc[@"longitude"] = [NSString stringWithFormat:@"%f", coordinate.longitude];
    for (id anno in _mapView.annotations) {
        if ([anno isKindOfClass:[DDPinAnnotation_DefaultLoc class]]) {
            [_mapView removeAnnotation:anno];
        }
    }
    
    DDPinAnnotation_DefaultLoc *anno = [[DDPinAnnotation_DefaultLoc alloc] initWithLocation:coordinate];
    [_mapView addAnnotation:anno];
    
    ((UIBarButtonItem *)[self.toolbar.items lastObject]).enabled = YES;
    UIActivityIndicatorView *aView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [aView startAnimating];
    self.navigationItem.rightBarButtonItem.customView = aView;
    
    CLLocation *touchLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    option.reverseGeoPoint = CLLocationCoordinate2DMake(touchLocation.coordinate.latitude, touchLocation.coordinate.longitude);
    _search = [[BMKGeoCodeSearch alloc] init];
    _search.delegate = self;
    [_search reverseGeoCode:option];
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    _search.delegate = nil;
    self.defaultLoc[@"address"] = result.address;
    [self.delegate didSetDefaultLoc:self.defaultLoc];
    
    DDPinAnnotation_DefaultLoc *anno = [_mapView.annotations firstObject];
    anno.title = result.address;
    [_mapView selectAnnotation:[_mapView.annotations firstObject] animated:YES];
    
    self.navigationItem.rightBarButtonItem.customView = nil;
    self.navigationItem.rightBarButtonItem = self.completeButton;

}

//TODO: add defaultLoc annotation
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    
    if (self.defaultLoc[@"address"]) {
        DDPinAnnotation_DefaultLoc *anno = [[DDPinAnnotation_DefaultLoc alloc] initWithLocation:CLLocationCoordinate2DMake([self.defaultLoc[@"latitude"] floatValue], [self.defaultLoc[@"longitude"] floatValue])];
        anno.title = self.defaultLoc[@"address"];
        [_mapView addAnnotation:anno];
        [_mapView selectAnnotation:[_mapView.annotations firstObject] animated:YES];
    }
    
    UIBarButtonItem *trackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bnavi"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(locateUser)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_deletepin"]
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self action:@selector(clearCustomLocation)];
    clearButton.enabled = self.defaultLoc[@"address"] ? YES : NO;
    
    self.toolbar.items = @[trackButton, space, clearButton];
    [self.view bringSubviewToFront:self.toolbar];
}

- (NSDictionary *)defaultLoc
{
    if (!_defaultLoc) {
        _defaultLoc = [[NSMutableDictionary alloc] init];
    }
    return _defaultLoc;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    self.navigationController.navigationBar.hidden = NO;
    [self locateUser];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
