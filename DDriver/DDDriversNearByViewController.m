//
//  DDDriversNearByViewController.m
//  DDriver11
//
//  Created by ZBN on 14-7-25.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

#import "DDDriversNearByViewController.h"
#import <BMapKit.h>
#import "DDDriver.h"
#import "DDMyAnnotationView.h"
#import "DDPinAnnotation.h"
#import "DDDriverDetailViewController.h"
#import "DDLocHandler.h"
#import "DDDataHandler.h"
#import "DDDriverCell.h"

@interface DDDriversNearByViewController () <BMKMapViewDelegate, DriverDelegate, MyAnnotationViewDelegate, DDAFManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
    BMKMapView *_mapView;
    DDAFManager *_manager;
}

@property (strong, nonatomic) NSArray *driversNearBy;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DDDriversNearByViewController

@synthesize driversNearBy = _driversNearBy;

- (IBAction)switchButtonTapped:(UIBarButtonItem *)sender
{
    _mapView.hidden = !_mapView.isHidden;
    self.tableView.hidden = !self.tableView.isHidden;
    if (!self.tableView.isHidden) {
        [self.tableView reloadData];
    }
}

//地图focus到手动定义的地址
- (void)moveToCustomLoc
{
    NSLog(@"%@:", NSStringFromSelector(_cmd));
    
    self.addressButton.hidden = NO;
    [self.addressButton setTitle:[DDDataHandler sharedData].customAddress forState:UIControlStateNormal];
    _mapView.showsUserLocation = NO;
    
    for (id anno in _mapView.annotations) {
        if ([anno isKindOfClass:[DDPinAnnotation class]]) {
            [_mapView removeAnnotation:anno];
        }
    }
    DDPinAnnotation *anno = [[DDPinAnnotation alloc] initWithLocation:[DDDataHandler sharedData].customLocation.coordinate];
    [_mapView addAnnotation:anno];
    
    BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance([DDDataHandler sharedData].customLocation.coordinate, 2000, 2000);
    [_mapView setRegion:[_mapView regionThatFits:region]];
    
    [self updateDriversNearByWithRegion:region];
}

//地图focus到自动定位的当前地址
- (void)moveToCurrentLoc
{
    NSLog(@"%@:", NSStringFromSelector(_cmd));
    self.addressButton.hidden = NO;
    _mapView.showsUserLocation = YES;
    [self.addressButton setTitle:[DDDataHandler sharedData].currentAddress forState:UIControlStateNormal];
    
    for (id anno in _mapView.annotations) {
        if ([anno isKindOfClass:[DDPinAnnotation class]]) {
            [_mapView removeAnnotation:anno];
        }
    }
    [_mapView updateLocationData:[DDDataHandler sharedData].userLocation];
    BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance([DDDataHandler sharedData].currentLocation.coordinate, 2000, 2000);
    [_mapView setRegion:[_mapView regionThatFits:region]];
    
    [self updateDriversNearByWithRegion:region];
}

- (void)updateDriversNearByWithRegion:(BMKCoordinateRegion)region
{
    CLLocationCoordinate2D center = region.center;
    NSString *latitudeStr = [NSString stringWithFormat:@"%f", center.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%f", center.longitude];
    NSDictionary *parameters = @{
                                 @"request" : @"getdriversnearby",
                                 @"session_id": [DDDataHandler sharedData].sessionID,
                                 @"region" : @{ @"latitude" : latitudeStr,
                                                @"longitude" : longitudeStr,
                                                @"latitudedistanceinmeters" : @"5000",
                                                @"longitudedistanceinmeters" : @"5000",
                                                @"city" : [DDDataHandler sharedData].city
                                                },
                                 @"client" : [DDDataHandler sharedData].appPlatform,
                                 @"version" : [DDDataHandler sharedData].appVersion
                                 };
    _manager = [[DDAFManager alloc] initWithURL:DRIVERSNEARBYURL parameters:parameters delegate:self];
   
}

- (void)AFManagerDidFinishDownload:(NSDictionary *)responseObj forURL:(NSString *)URL
{
    self.navigationItem.rightBarButtonItem.customView = nil;
    
    if ([URL isEqualToString:DRIVERSNEARBYURL]) {
        self.navigationItem.rightBarButtonItem.customView = nil;
        
        NSMutableArray *driversReceived = [[NSMutableArray alloc] init];
        
        for (NSDictionary *driverData in responseObj[@"drivers"]) {
            DDDriver *driver = [[DDDriver alloc] initWithLocation:CLLocationCoordinate2DMake([driverData[@"latitude"] floatValue], [driverData[@"longitude"] floatValue])];
            driver.delegate = self;
            driver.driverID = driverData[@"driverid"];
            driver.name = driverData[@"name"];
            driver.jobCount = driverData[@"jobcount"];
            driver.rateStar = driverData[@"stars"];
            driver.rateTitle = driverData[@"is_crown"] ? @"皇冠司机" : @"";
            CLLocation *driverLocation = [[CLLocation alloc] initWithLatitude:driver.coordinate.latitude longitude:driver.coordinate.longitude];
            driver.distanceInKM = [[DDDataHandler sharedData].currentLocation distanceFromLocation:driverLocation] / 1000.0;
            driver.avatarURL = driverData[@"avatar"];
            
            [driversReceived addObject:driver];
        }
        self.driversNearBy = [NSArray arrayWithArray:driversReceived];
        _manager = nil;
    }
}

- (void)AFManagerDidFailedDownloadForURL:(NSString *)URL error:(NSString *)message
{
    self.navigationItem.rightBarButtonItem.customView = nil;
    [DDDataHandler blankTitleAlert:message];
    _manager = nil;
}

- (void)AFManagerDidGetResultErrorForURL:(NSString *)URL error:(NSString *)message
{
    self.navigationItem.rightBarButtonItem.customView = nil;
    [DDDataHandler blankTitleAlert:message];
    _manager = nil;
}


- (void)updateMapViewAnnotations
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    [_mapView addAnnotations:self.driversNearBy];
    
    if ([DDDataHandler sharedData].customLocation) {
        DDPinAnnotation *anno = [[DDPinAnnotation alloc] initWithLocation:[DDDataHandler sharedData].customLocation.coordinate];
        [_mapView addAnnotation:anno];
    }
}

- (void)respondsToLocFail
{
    self.navigationItem.rightBarButtonItem.customView = nil;
}

#pragma mark - BMKMapview Delegate

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    static NSString *reuseID = @"DriverOnMap";
    BMKAnnotationView *viewToReturn;
    
    if ([annotation isKindOfClass:[DDDriver class]]) {
        
        DDMyAnnotationView *aView = (DDMyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
        
        if (!aView) {
            aView = [[DDMyAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:nil];
        }
        DDDriver *driver = (DDDriver *)annotation;
        
        driver.avatar = [UIImage imageNamed:@"driver_defaultavatar"];
        aView.avatarView.image = driver.avatar;
        aView.nameLabel.text = driver.name;
        aView.distanceLabel.text = [NSString stringWithFormat:@"%.2f公里", driver.distanceInKM];
        aView.rateStarLabel.text = driver.rateStar;
        //司机是皇冠司机
        if (![driver.rateTitle isEqualToString:@""]) {
            aView.rateLabel.text = driver.rateTitle;
        };
        aView.annotation = annotation;
        aView.delegate = self;
        viewToReturn = aView;
        //手动设定的地址
    }
    else if ([annotation isKindOfClass:[DDPinAnnotation class]]) {
//        viewToReturn = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
//        viewToReturn.canShowCallout = YES;
    }
    else {
//        viewToReturn.annotation = annotation;
    }
    
    return viewToReturn;
}


#pragma mark - MyAnnotationView Delegate

- (void)myAnnotationView:(DDMyAnnotationView *)aView bubbleViewTapped:(UIControl *)control
{
    if ([aView.annotation isKindOfClass:[DDDriver class]]) {
        
        [self performSegueWithIdentifier:@"DRIVERDETAILVC" sender:aView];
    }
}

#pragma mark - DriverDelegate

- (void)didDownloadAvatarImageForDriver:(DDDriver *)driver
{
    if (self.tableView.hidden) {
//        NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
        for (DDDriver *theDriver in self.driversNearBy) {
            if ([theDriver.driverID isEqualToString:driver.driverID]) {
                
                DDMyAnnotationView *myAnnoView = (DDMyAnnotationView *)[_mapView viewForAnnotation:theDriver];
                NSLog(@"%@, %@", theDriver.driverID, myAnnoView);
                myAnnoView.avatarView.image = driver.avatar;
            }
        }
        
    } else {
        for (DDDriver *driverOnList in self.driversNearBy) {
            if ([driverOnList.driverID isEqualToString:driver.driverID]) {
                int i = [self.driversNearBy indexOfObject:driverOnList];
                DDDriverCell *cell = (DDDriverCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.avatarView.image = driver.avatar;
            }
        }
    }
}

#pragma mark - Tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.driversNearBy count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.driversNearBy count]==0) {
        return nil;
    }
    static NSString *CellIdentifier = @"DriverCell";
    DDDriverCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DDDriver *driver = [self.driversNearBy objectAtIndex:indexPath.row];

    cell.avatarView.image = driver.avatar;
    cell.nameLabel.text = driver.name;
    cell.rateStarLabel.text = driver.rateStar;
    
    //此时开始下载司机头像, 成功后通过delegate call更新.
    driver.avatarURL = driver.avatarURLTemp;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"DRIVERDETAILVC" sender:indexPath];
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];

    [self.view addSubview:_mapView];
    [self.view bringSubviewToFront:self.addressButton];
    
    UINib *nib = [UINib nibWithNibName:@"DDDriverCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DriverCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    
    UIActivityIndicatorView *iView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem.customView = iView;
    [iView startAnimating];
    
    if ([DDDataHandler sharedData].customAddress) {
        [self moveToCustomLoc];

    } else {
        
        if ([DDDataHandler sharedData].currentAddress) {
            [_mapView updateLocationData:[DDDataHandler sharedData].userLocation];
            BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance([DDDataHandler sharedData].currentLocation.coordinate, 2000, 2000);
            [_mapView setRegion:[_mapView regionThatFits:region]];
        }
        if (![DDLocHandler sharedLocater].isActive) [[DDLocHandler sharedLocater] updateCurrentLocationAndAddress];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToCurrentLoc) name:@"CurrentAddressUpdated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondsToLocFail) name:@"UserLocatingFailed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondsToLocFail) name:@"NoValidCity" object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _mapView.showsUserLocation = YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)driversNearBy
{
    if (!_driversNearBy) {
        _driversNearBy = [[NSArray alloc] init];
    }
    return _driversNearBy;
}

- (void)setDriversNearBy:(NSMutableArray *)driversNearBy
{
    _driversNearBy  = driversNearBy;
    
    [self updateMapViewAnnotations];
    if (!self.tableView.isHidden) {
        [self.tableView reloadData];
    }
}

#pragma mark - segue navi

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DRIVERDETAILVC"] && [sender isKindOfClass:[DDMyAnnotationView class]]) {
        if ([segue.destinationViewController isKindOfClass:[DDDriverDetailViewController class]]) {
            DDDriverDetailViewController *ddvc = segue.destinationViewController;
            ddvc.driver = ((DDMyAnnotationView *)sender).annotation;
        }
    } else if ([segue.identifier isEqualToString:@"DRIVERDETAILVC"] && [sender isKindOfClass:[NSIndexPath class]]) {
        DDDriverDetailViewController *ddvc = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        ddvc.driver = self.driversNearBy[indexPath.row];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}


@end
