//
//  SpotifyHelper.m
//  Mood Music Thing
//
//  Created by Vladimir Danila on 15/10/2016.
//  Copyright © 2016 Alexsander Akers. All rights reserved.
//

#import <ScriptingBridge/ScriptingBridge.h>

#import "Spotify.h"
#import "SpotifyHelper.h"

@implementation SpotifyHelper

+ (BOOL)playTrack:(NSString *)trackID inContext:(NSString *)context
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.isRunning) {
        [spotify playTrack:trackID inContext:context];
        return YES;
    } else {
        return NO;
    }
}

@end
