//
//  CLDataHandler.h
//  CamLocker
//
//  Created by FlyinGeek on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import "AFNetworking.h"
#import <Foundation/Foundation.h>

typedef enum {
    CLDataHandlerOptionSuccess,
    CLDataHandlerOptionFailure
}CLDataHandlerOption;

@interface CLDataHandler : NSObject

+ (void)uploadMarker:(CLMarker *)marker completionBlock:(void (^)(CLDataHandlerOption option, NSURL *markerURL, NSError *error))completion;
+ (void)downloadMarkerBy:(NSString *)identifier completionBlock:(void (^)(CLDataHandlerOption option, NSDictionary *markerData, NSError *error))completion;

@end