//
//  NativeDataSourceTests.m
//  NativeDataSourceTests
//
//  Created by Steve Sng on 07/27/2014.
//  Copyright (c) 2014 lovebyte. All rights reserved.
//

#import <NativeDataSource.h>

@interface NativeDataSource()

@property (nonatomic, strong) NSMutableDictionary *adClassNames;

@end

@interface MockData : NSObject @end
@implementation MockData @end

@interface MockNativeAd : NSObject @end
@implementation MockNativeAd @end


SPEC_BEGIN(NativeDataSourceSpec)

describe(@"NativeDataSource", ^{
    
    __block NativeDataSource *nativeDataSource;
    
    beforeEach(^{
        nativeDataSource = [[NativeDataSource alloc] init];
    });
    
    it(@"has default properties", ^{
        //        [[theValue(nativeDataSource.placementPolicy) should] equal:theValue(NativeAdFixedPlacement)];
        //        [[theValue(nativeDataSource.fixedPlacementRate) should] equal:theValue(10)]];
        //        [[theValue(nativeDataSource.placementOffset) should] equal:theValue(2)]];
        //        [[theValue(nativeDataSource.shouldRecycleNativeAd) should] equal:theValue(NO)]];
        [[theValue(nativeDataSource.placementPolicy == NativeAdFixedPlacement) should] beTrue];
        [[theValue(nativeDataSource.fixedPlacementRate == 10) should] beTrue];
        [[theValue(nativeDataSource.placementOffset == 2) should] beTrue];
        [[theValue(nativeDataSource.shouldRecycleNativeAd == NO) should] beTrue];
    });
    
    describe(@"insertData", ^{
        
        __block NSArray *newData;
        
        beforeEach(^{
            newData = @[[MockData new],
                        [MockData new],
                        [MockData new]];
        });
        
        it(@"inserts data", ^{
            [nativeDataSource insertData:newData];
            [[nativeDataSource.data should] containObjectsInArray:newData];
        });
        
        it(@"inserts data behind existing data", ^{
            NSArray *existingData = @[[MockData new], [MockData new]];
            [nativeDataSource.data addObjectsFromArray:existingData];
            [nativeDataSource insertData:newData];
            [[nativeDataSource.data should] containObjectsInArray:existingData];
            [[[nativeDataSource.data objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, [newData count])]] should] containObjectsInArray:newData];
        });
        
        context(@"placement policy is fixed", ^{
            
            beforeEach(^{
                [nativeDataSource setPlacementPolicy:NativeAdFixedPlacement];
            });
            
            it(@"inserts native ad from pool", ^{
                MockNativeAd *nativeAd = [MockNativeAd new];
                [nativeDataSource.nativeAds addObject:nativeAd];
                [nativeDataSource insertData:newData];
                [[[nativeDataSource.data objectAtIndex:nativeDataSource.placementOffset] should] equal:nativeAd];
            });
            
            it(@"inserts placeholder if pool is empty", ^{
                [nativeDataSource.nativeAds removeAllObjects];
                [nativeDataSource insertData:newData];
                [[[nativeDataSource.data objectAtIndex:nativeDataSource.placementOffset] should] beKindOfClass:[NSNull class]];
            });
        });
        
        context(@"placement policy is dynamic", ^{
            
            beforeEach(^{
                [nativeDataSource setPlacementPolicy:NativeAdDynamicPlacement];
                [nativeDataSource.data addObjectsFromArray:@[[MockData new],
                                                             [MockData new],
                                                             [MockData new],
                                                             [MockData new],
                                                             [MockData new]]];
                [[nativeDataSource.data should] haveCountOf:5];
            });
            
            it(@"inserts native ad from pool", ^{
                MockNativeAd *nativeAd = [MockNativeAd new];
                [nativeDataSource.nativeAds addObject:nativeAd];
                NSInteger row = [nativeDataSource.data count] - nativeDataSource.placementOffset - 1;
                [nativeDataSource setVisibleIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                [nativeDataSource insertData:newData];
                [[nativeDataSource.data should] contain:nativeAd];
                [[[nativeDataSource.data objectAtIndex:(row+nativeDataSource.placementOffset)] should] equal:nativeAd];
            });
        });
        
    });
    
    describe(@"insertNativeAd", ^{
        
        __block MockNativeAd *newNativeAd;
        
        beforeEach(^{
            newNativeAd = [MockNativeAd new];
        });
        
        it(@"registers class of object as one of the managed native ad classes", ^{
            [nativeDataSource insertNativeAd:newNativeAd];
            [[nativeDataSource.adClassNames should] haveValueForKey:NSStringFromClass([MockNativeAd class])];
        });
        
        context(@"placement policy is fixed", ^{
            
            beforeEach(^{
                [nativeDataSource setPlacementPolicy:NativeAdFixedPlacement];
            });
            
            it(@"replaces first placeholder found with native ad", ^{
                NSNull *placeholder = [NSNull new];
                [nativeDataSource.data addObject:[NSNull new]];
                [nativeDataSource insertNativeAd:newNativeAd];
                [[nativeDataSource.data should] contain:newNativeAd];
                [[nativeDataSource.data shouldNot] contain:placeholder];
            });
            
            it(@"adds native ad to pool if no placeholder found", ^{
                [nativeDataSource insertNativeAd:newNativeAd];
                [[nativeDataSource.data shouldNot] contain:newNativeAd];
                [[nativeDataSource.nativeAds should] contain:newNativeAd];
            });
        });
        
        context(@"placement policy is dynamic", ^{
            
            beforeEach(^{
                [nativeDataSource setPlacementPolicy:NativeAdDynamicPlacement];
                [nativeDataSource.data addObjectsFromArray:@[[MockData new],
                                                             [MockData new],
                                                             [MockData new],
                                                             [MockData new],
                                                             [MockData new]]];
                [[nativeDataSource.data should] haveCountOf:5];
            });
            
            it(@"inserts native ad after visible index path", ^{
                NSInteger row = [nativeDataSource.data count] - nativeDataSource.placementOffset - 1;
                [nativeDataSource setVisibleIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                [nativeDataSource insertNativeAd:newNativeAd];
                [[nativeDataSource.data should] contain:newNativeAd];
                [[[nativeDataSource.data objectAtIndex:(row+nativeDataSource.placementOffset)] should] equal:newNativeAd];
            });
            
            it(@"adds native ad to pool if visible index path is out of bound", ^{
                NSInteger row = [nativeDataSource.data count];
                [nativeDataSource setVisibleIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                [nativeDataSource insertNativeAd:newNativeAd];
                [[nativeDataSource.data shouldNot] contain:newNativeAd];
                [[nativeDataSource.nativeAds should] contain:newNativeAd];
            });
        });
        
    });
    
    describe(@"isNativeAdAtIndexPath", ^{
        
        __block NSIndexPath *indexPath;
        
        beforeEach(^{
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        });
        
        it(@"returns true if object at index path belongs to one of the managed native ad classes", ^{
            [nativeDataSource.adClassNames setObject:NSStringFromClass([MockNativeAd class]) forKey:NSStringFromClass([MockNativeAd class])];
            [nativeDataSource.data addObject:[MockNativeAd new]];
            BOOL result = [nativeDataSource isNativeAdAtIndexPath:indexPath];
            [[theValue(result) should] beTrue];
        });
        
        it(@"returns false if object at index path does not belong to one of the managed native ad classes", ^{
            [nativeDataSource.data addObject:[MockData new]];
            BOOL result = [nativeDataSource isNativeAdAtIndexPath:indexPath];
            [[theValue(result) should] beFalse];
        });
        
        it(@"returns true if object at index path is placeholder", ^{
            [nativeDataSource.data addObject:[NSNull new]];
            BOOL result = [nativeDataSource isNativeAdAtIndexPath:indexPath];
            [[theValue(result) should] beTrue];
        });
        
        it(@"returns false if index path is out of bound", ^{
            BOOL result = [nativeDataSource isNativeAdAtIndexPath:indexPath];
            [[theValue(result) should] beFalse];
        });
        
    });
    
    describe(@"isObjectNativeAd", ^{
        
        it(@"returns true if object belongs to one of the managed native ad classes", ^{
            [nativeDataSource.adClassNames setObject:NSStringFromClass([MockNativeAd class]) forKey:NSStringFromClass([MockNativeAd class])];
            BOOL result = [nativeDataSource isObjectNativeAd:[MockNativeAd new]];
            [[theValue(result) should] beTrue];
        });
        
        it(@"returns false if object does not belong to one of the managed native ad classes", ^{
            BOOL result = [nativeDataSource isObjectNativeAd:[MockData new]];
            [[theValue(result) should] beFalse];
        });
        
        it(@"returns true if object is placeholder", ^{
            BOOL result = [nativeDataSource isObjectNativeAd:[NSNull new]];
            [[theValue(result) should] beTrue];
        });
        
        it(@"returns false if object is nil", ^{
            BOOL result = [nativeDataSource isObjectNativeAd:nil];
            [[theValue(result) should] beFalse];
        });
        
    });
    
});

SPEC_END