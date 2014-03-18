//
//  CLMarker.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLMarker : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *markerImageFileName;
@property (nonatomic, copy, readonly) NSString *markerImagePath;
@property (nonatomic, copy, readonly) NSString *cosName;

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype)initWithMarkerImage:(UIImage *)markerImage;


- (void)activate;
- (void)deactivate;

- (void)deleteContent;

@end