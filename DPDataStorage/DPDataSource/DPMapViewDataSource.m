//
//  DPMapViewDataSource.m
//  DPDataStorage
//
//  Created by Alex Bakhtin on 5/10/17.
//  Copyright © 2017 EffectiveSoft. All rights reserved.
//

#import "DPMapViewDataSource.h"

@implementation DPMapViewDataSource

- (void)setMapView:(MKMapView *)mapView {
    if (_mapView != mapView) {
        _mapView = mapView;
        [self reloadAnnotations];
        [self showNoDataViewIfNeeded];
    }
}

- (void)setCellIdentifier:(NSString *)cellIdentifier {
    super.cellIdentifier = [cellIdentifier copy];
    [self reloadAnnotations];
}

- (void)setListController:(id<DataSourceContainerController>)listController {
    if (super.listController) {
        [self.mapView removeAnnotations:super.listController.fetchedObjects];
    }
    [super setListController:listController];
    [self reloadAnnotations];
    [self showNoDataViewIfNeeded];
}

- (void)setAnnotationViewClass:(NSString *)annotationViewClass {
    if (_annotationViewClass != annotationViewClass) {
        _annotationViewClass = annotationViewClass;
        [self reloadAnnotations];
    }
}

- (void)setNoDataView:(UIView *)noDataView {
    if (super.noDataView != noDataView) {
        [super.noDataView removeFromSuperview];
        super.noDataView = noDataView;
        [self showNoDataViewIfNeeded];
    }
}

#pragma mark - Init

- (instancetype)initWithMapView:(MKMapView *)mapView listController:(id<DataSourceContainerController>)listController forwardDelegate:(id)forwardDelegate cellIdentifier:(NSString *)cellIdentifier {
    if ((self = [super init])) {
        self.cellIdentifier = cellIdentifier;

        self.forwardDelegate = forwardDelegate;
        self.listController = listController;
        self.listController.delegate = self;

        mapView.delegate = self;
        self.mapView = mapView;
    }

    return self;
}

- (void)reloadAnnotations {
    if (self.mapView == nil || self.listController == nil || self.cellIdentifier == nil || self.annotationViewClass == nil) return;

    for (id<MKAnnotation> annotation in self.listController.fetchedObjects) {
        if ([annotation conformsToProtocol:@protocol(MKAnnotation)]) {
            [self.mapView addAnnotation:annotation];
        }
        else {
            NSString *reason = [NSString stringWithFormat:@"Type '%@' does not conform to protocol '%@'", NSStringFromClass(annotation.class), NSStringFromProtocol(@protocol(MKAnnotation))];
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = nil;
    if ([self.forwardDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        annotationView = [(id<MKMapViewDelegate>)self.forwardDelegate mapView:mapView viewForAnnotation:annotation];
    }

    if (annotationView == nil) {
        annotationView = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:self.cellIdentifier];
        if (annotationView == nil) {
            annotationView = [[NSClassFromString(self.annotationViewClass) alloc] initWithAnnotation:annotation reuseIdentifier:self.cellIdentifier];
        }
        else {
            annotationView.annotation = annotation;
        }

        if ([annotationView conformsToProtocol:@protocol(DPDataSourceCell)]) {
            MKAnnotationView<DPDataSourceCell> *dataSourceCell = (id)annotationView;
            [dataSourceCell configureWithObject:annotation];
        }
        else {
            NSString *reason = [NSString stringWithFormat:@"Type '%@' does not conform to protocol '%@'", self.annotationViewClass, NSStringFromProtocol(@protocol(DPDataSourceCell))];
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        }
    }

    return annotationView;
}

#pragma mark - NoData view

- (void)showNoDataViewIfNeeded {
    [self setNoDataViewHidden:[self hasData]];
}

- (void)setNoDataViewHidden:(BOOL)hidden {
    if (self.noDataView == nil || self.mapView == nil) return;
    NSAssert(false, @"Not implemented");
}

#pragma mark - NSFetchedResultsController

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    if (controller == self.listController && self.mapView.delegate != nil) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.mapView addAnnotation:anObject];
                break;

            case NSFetchedResultsChangeDelete:
                [self.mapView removeAnnotation:anObject];
                break;

            case NSFetchedResultsChangeUpdate:
                [self.mapView removeAnnotation:anObject];
                [self.mapView addAnnotation:anObject];
                break;

            case NSFetchedResultsChangeMove:
                break;
        }
    };
    [self showNoDataViewIfNeeded];
}

@end
