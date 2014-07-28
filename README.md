# NativeDataSource

[![CI Status](http://img.shields.io/travis/lovebyte/NativeDataSource.svg?style=flat)](https://travis-ci.org/lovebyte/NativeDataSource)
[![Version](https://img.shields.io/cocoapods/v/NativeDataSource.svg?style=flat)](http://cocoadocs.org/docsets/NativeDataSource)
[![License](https://img.shields.io/cocoapods/l/NativeDataSource.svg?style=flat)](http://cocoadocs.org/docsets/NativeDataSource)
[![Platform](https://img.shields.io/cocoapods/p/NativeDataSource.svg?style=flat)](http://cocoadocs.org/docsets/NativeDataSource)

NativeDataSource is an implementation of the UITableViewDataSource protocol that manages the placement of native ads within native contents.

## Usage

### Managing data

After loading your data, pass them to NativeDataSource to let it manage:

    [nativeDataSource insertData:dataLoaded];

After loading native ad from your ad provider, pass it to NativeDataSource to let it manage:

    [nativeDataSource insertNativeAd:nativeAdLoaded];

### Displaying data

    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    	[nativeDataSource setVisibleIndexPath:indexPath]; // required for dynamic ad placement

    	if ([nativeDataSource isNativeAdAtIndexPath:indexPath]) {

    		[nativeDataSource.data objectAtIndex:indexPath.row]; // this is native ad

    		...

    	} else {

    		[nativeDataSource.data objectAtIndex:indexPath.row]; // this is native content

    		...
    	}
    }


----

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS SDK 7.0 and above

## Installation

NativeDataSource is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "NativeDataSource"

## Author

[Steve Sng](https://github.com/stevesng)

## License

NativeDataSource is available under the MIT license. See the LICENSE file for more info.
