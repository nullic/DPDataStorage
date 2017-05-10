//
//  DPMapViewDataSource.h
//  DPDataStorage
//
//  Created by Alex Bakhtin on 5/10/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

#import <DPDataStorage/DPDataStorage.h>
#import <MapKit/MapKit.h>

@interface DPMapViewDataSource : DPBaseDataSource <MKMapViewDelegate>
@property (nonatomic, weak, nullable) IBOutlet MKMapView *mapView;
@property (nonatomic, copy, nullable) IBInspectable NSString *annotationViewClass; // View must conform <DPDataSourceCell>

- (instancetype _Nonnull)initWithMapView:(MKMapView * _Nullable)mapView listController:(id<DataSourceContainerController> _Nullable)listController forwardDelegate:(id _Nullable)forwardDelegate cellIdentifier:(NSString * _Nullable)cellIdentifier;

@end
