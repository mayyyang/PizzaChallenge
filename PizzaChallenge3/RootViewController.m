//
//  ViewController.m
//  PizzaChallenge3
//
//  Created by May Yang on 11/5/14.
//  Copyright (c) 2014 May Yang. All rights reserved.
//

#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Pizzeria.h"
@import MapKit;

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) NSMutableArray *pizzeriaArray;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pizzeriaArray = [NSMutableArray array];
    self.manager = [[CLLocationManager alloc]init];
    [self.manager requestWhenInUseAuthorization];
    self.manager.delegate = self;
}



- (IBAction)findButton:(UIButton *)sender
{
    self.manager.distanceFilter = kCLDistanceFilterNone;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager startUpdatingLocation];
    NSLog(@"help");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error %@", error);

}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy <1000)
        {
            NSLog(@"Found your location");

            [self reverseGeocode:location];
            [self.manager stopUpdatingLocation];
            break;
        }
    }
    CLLocation *currentLocation = [locations lastObject];
}


- (void)reverseGeocode:(CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        [self findPizzeriaNear:placemark.location];
    }];
}
- (void)findPizzeriaNear:(CLLocation *)location
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizzeria";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));

    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;

        for (int i=0; i<=3; i++)
        {
            if (i < mapItems.count)
            {
                [self.pizzeriaArray addObject:mapItems[i]];
            }
        }
        [self.tableView reloadData];

//        MKMapItem *mapItem = mapItems.firstObject;
    }];
}

-(void)findDistancePizzeria:(CLLocation *)location
{
    NSMutableArray *distances = [NSMutableArray array];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pizzeriaArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Pizzeria *pizzera = self.pizzeriaArray[indexPath.row];
    cell.textLabel.text = pizzera.name;
    return cell;
    
}

@end
