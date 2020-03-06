//
//  DPMapViewDataSource.h
//  DPDataStorage
//
//  Created by Alex Bakhtin on 5/10/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

#if TARGET_OS_IOS
#import "DPBaseDataSource.h"
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPMapViewDataSource : DPBaseDataSource <MKMapViewDelegate>
@property (nonatomic, weak, nullable) IBOutlet MKMapView *mapView;
@property (nonatomic, copy, nullable) IBInspectable NSString *annotationViewClass; // View must conform <DPDataSourceCell>
@property (nonatomic, strong, nullable) IBOutlet UIView *noDataView;
@property (nonatomic, copy, nullable) IBInspectable NSString *annotationViewIdentifier;

- (instancetype)initWithMapView:(MKMapView * _Nullable)mapView listController:(id<DataSourceContainerController> _Nullable)listController forwardDelegate:(id _Nullable)forwardDelegate annotationViewIdentifier:(NSString *)annotationViewIdentifier;

- (void)addAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnnotation:(id<MKAnnotation>)annotation;

@end

NS_ASSUME_NONNULL_END
#endif
