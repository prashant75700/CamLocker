//
//  CLImageMarker.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import <Foundation/Foundation.h>

@interface CLImageMarker : CLMarker <NSCoding>

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithMarkerImage:(UIImage *)markerImage __attribute__ ((unavailable("initWithMarkerImage: not available")));

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                       hiddenImages:(NSArray *)hiddenImages;

- (NSArray *)hiddenImages;
- (void)deleteContent;

@end