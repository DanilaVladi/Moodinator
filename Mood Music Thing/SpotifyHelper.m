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
    }

    return NO;
}

+(BOOL)pause
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.isRunning) {
        [spotify pause];
        return YES;
    }

    return NO;
}

+(BOOL)resume
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.isRunning) {
        [spotify play];
        return YES;
    }

    return NO;
}

+(BOOL)nextTrack
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.isRunning) {
        [spotify nextTrack];
        return YES;
    }

    return NO;
}

+(BOOL)previousTrack
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.isRunning) {
        [spotify previousTrack];
        return YES;
    }

    return NO;
}

+ (NSInteger)duration
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    if (spotify.isRunning && [spotify respondsToSelector: @selector(currentTrack)]) {
        if ([spotify.currentTrack respondsToSelector:@selector(duration)])
            return (spotify.currentTrack.duration/1000) - spotify.playerPosition;
    }

    return 0;
}

@end
