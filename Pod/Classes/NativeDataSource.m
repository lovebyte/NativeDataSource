//
//  NativeDataSource.m
//  LoveByte
//
//  Created by Steve Sng on 23/7/14.
//  Copyright (c) 2014 lovebyte. All rights reserved.
//

#import "NativeDataSource.h"

@interface NativeDataSource()

@property (nonatomic, strong) NSMutableDictionary *adClassNames;

@end

@implementation NativeDataSource

- (id)init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableArray array];
        self.nativeAds = [NSMutableArray array];
        self.adClassNames = [NSMutableDictionary dictionaryWithObject:NSStringFromClass([NSNull class]) forKey:NSStringFromClass([NSNull class])];
        self.fixedPlacementRate = 10;
        self.placementOffset = 2;
    }
    return self;
}

- (void)insertData:(NSArray *)newData
{
    NSUInteger startIndex = ([_data count]/_fixedPlacementRate + (([_data count]%_fixedPlacementRate > 0) ? 1 : 0)) * _fixedPlacementRate;
    
    [_data addObjectsFromArray:newData];
    
    if (_placementPolicy == NativeAdFixedPlacement) {
        
        NSUInteger nextIndex = startIndex + _placementOffset;
        while (nextIndex < [_data count]) {
            if ([_nativeAds count] > 0) {
                [self insertNativeAdAtIndex:nextIndex];
            } else {
                [_data insertObject:[NSNull null] atIndex:nextIndex];
            }
            nextIndex = nextIndex + _fixedPlacementRate;
        }
        
    } else if (_placementPolicy == NativeAdDynamicPlacement) {
        
        NSIndexPath *indexPath = [self findIndexPathForDynamicPlacement];
        if (indexPath && ([_nativeAds count] > 0)) {
            [self insertNativeAdAtIndex:indexPath.row];
        }
    }
}

- (void)insertNativeAd:(id)nativeAd
{
    [_adClassNames setObject:NSStringFromClass([nativeAd class]) forKey:NSStringFromClass([nativeAd class])];
    
    if (_placementPolicy == NativeAdFixedPlacement) {
        
        NSIndexPath *indexPath = [self findIndexPathForFixedPlacement];
        if (indexPath) {
            [_data replaceObjectAtIndex:indexPath.row withObject:nativeAd];
            (_shouldRecycleNativeAd) ? [_nativeAds addObject:nativeAd] : nil;
        } else {
            [_nativeAds addObject:nativeAd];
        }
        
    } else if (_placementPolicy == NativeAdDynamicPlacement) {
        
        NSIndexPath *indexPath = [self findIndexPathForDynamicPlacement];
        if (indexPath) {
            [_data insertObject:nativeAd atIndex:indexPath.row];
            (_shouldRecycleNativeAd) ? [_nativeAds addObject:nativeAd] : nil;
        } else {
            [_nativeAds addObject:nativeAd];
        }
    }
}

- (BOOL)isNativeAdAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_data count]) {
        return [self isObjectNativeAd:[_data objectAtIndex:indexPath.row]];
    } else {
        return NO;
    }
}

- (BOOL)isObjectNativeAd:(id)object
{
    return ([_adClassNames objectForKey:NSStringFromClass([object class])] != nil);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isNativeAdAtIndexPath:indexPath]) {
        return [self tableView:tableView nativeAdCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:tableView dataCellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Template Methods

- (UITableViewCell *)tableView:(UITableView *)tableView nativeAdCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"This method should be overriden to return the cell for displaying native ad");
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView dataCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"This method should be overridden to return the cell for displaying data");
    return nil;
}

#pragma mark - Internal methods

- (NSIndexPath *)findIndexPathForFixedPlacement
{
    for (int i=0; i<[_data count]; i++) {
        if ([[_data objectAtIndex:i] isKindOfClass:[NSNull class]]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

//TODO - use scroll direction and placement spacing for better placement
- (NSIndexPath *)findIndexPathForDynamicPlacement
{
    NSUInteger index = _visibleIndexPath ? _visibleIndexPath.row + _placementOffset : _placementOffset;
    if (index < [_data count]) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    } else {
        return nil;
    }
}

- (void)insertNativeAdAtIndex:(NSUInteger)index
{
    id nativeAd = [_nativeAds firstObject];
    [_data insertObject:nativeAd atIndex:index];
    [_nativeAds removeObject:nativeAd];
    (_shouldRecycleNativeAd) ? [_nativeAds addObject:nativeAd] : nil;
}

@end
