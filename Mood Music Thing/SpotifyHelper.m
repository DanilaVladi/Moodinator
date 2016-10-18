//
//  SpotifyHelper.m
//  Mood Music Thing
//
//  Created by Vladimir Danila & Alexsander Akersa on 15/10/2016.
//  Copyright © 2016 Vladimir Danila & Alexsander Akers. All rights reserved.
//

#import <ScriptingBridge/ScriptingBridge.h>

#import "Spotify.h"
#import "SpotifyHelper.h"

@implementation SpotifyHelper

+ (void)playTrack:(NSString *)trackID inContext:(NSString *)context
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if (!spotify.isRunning)
		[self.class lauchSpotify];

        [spotify playTrack:trackID inContext:context];
}

+ (void)pause
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if (!spotify.isRunning)
		[self.class lauchSpotify];

	[spotify pause];
}

+ (void)resume
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if (!spotify.isRunning)
		[self.class lauchSpotify];

	[spotify play];
}

+ (void)nextTrack
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if (!spotify.isRunning)
		[self.class lauchSpotify];

	[spotify nextTrack];
}

+ (void)previousTrack
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if (!spotify.isRunning)
		[self.class lauchSpotify];

	[spotify previousTrack];
}

+ (NSInteger)duration
{
    SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if (!spotify.isRunning)
		[self.class lauchSpotify];

	if ([spotify respondsToSelector: @selector(currentTrack)]) {
        if ([spotify.currentTrack respondsToSelector:@selector(duration)])
            return (spotify.currentTrack.duration/1000) - spotify.playerPosition;
    }

    return 0;
}

+ (void)lauchSpotify
{
	SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
	if (!spotify.isRunning) {
		NSAppleScript *script = [[NSAppleScript alloc]
								 initWithSource:@"tell app \"Spotify\" to launch"];
		NSDictionary *errorInfo;
		[script executeAndReturnError:&errorInfo];
		if (errorInfo) {
			NSLog(@"error: %@", errorInfo);
		}
	}
}

@end
