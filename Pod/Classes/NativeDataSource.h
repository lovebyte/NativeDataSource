//
//  NativeDataSource.h
//  LoveByte
//
//  Created by Steve Sng on 23/7/14.
//  Copyright (c) 2014 lovebyte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    NativeAdFixedPlacement = 0, //default
    NativeAdDynamicPlacement
} NativeAdPlacementPolicy;

@interface NativeDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, assign) NativeAdPlacementPolicy placementPolicy;
@property (nonatomic, assign) NSUInteger fixedPlacementRate;
@property (nonatomic, assign) NSUInteger placementOffset;
@property (nonatomic, assign) BOOL shouldRecycleNativeAd;

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *nativeAds;
@property (nonatomic, strong) NSIndexPath *visibleIndexPath;

- (void)insertData:(NSArray *)newData;
- (void)insertNativeAd:(id)nativeAd;
- (BOOL)isNativeAdAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isObjectNativeAd:(id)object;

@end
