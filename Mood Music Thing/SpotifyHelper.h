//
//  SpotifyHelper.h
//  Mood Music Thing
//
//  Created by Vladimir Danila & Alexsander Akers on 15/10/2016.
//  Copyright © 2016 Vladimir Danila & Alexsander Akers. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyHelper : NSObject

+ (void)playTrack:(NSString *)trackID inContext:(nullable NSString *)context;

+ (void)pause;
+ (void)resume;

+ (void)nextTrack;
+ (void)previousTrack;

+ (NSInteger)duration;

@end

NS_ASSUME_NONNULL_END
