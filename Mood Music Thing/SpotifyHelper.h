//
//  SpotifyHelper.h
//  Mood Music Thing
//
//  Created by Vladimir Danila on 15/10/2016.
//  Copyright © 2016 Alexsander Akers. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyHelper : NSObject

+ (BOOL)playTrack:(NSString *)trackID inContext:(nullable NSString *)context;

@end

NS_ASSUME_NONNULL_END
