//
//  SSURadioStreamer.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/22/14.
//  Copyright (c) 2014 Sonoma State University Department of Computer Science. All rights reserved.
//

@import Foundation;
@import AVFoundation;
#import "SSURadioConstants.h"

@class SSURadioStreamer;

#pragma mark -
#pragma mark - SSURadioStreamerDelegate

@protocol SSURadioStreamerDelegate <NSObject>

@optional
- (void) streamer:(SSURadioStreamer *)radioStreamer receivedTimeUpdate:(CMTime)time;
- (void) streamer:(SSURadioStreamer *)radioStreamer playerStatusDidChange:(AVPlayerStatus)status;

@end

@interface SSURadioStreamer : NSObject

#pragma mark -
#pragma mark - Properties

@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic) int32_t timeScale;
@property (nonatomic) int64_t timeInterval;
@property (nonatomic, weak) id<SSURadioStreamerDelegate> delegate;

#pragma mark -
#pragma mark - Initializers

- (instancetype) init;
- (instancetype) initWithURL:(NSURL *)URL;

#pragma mark -
#pragma mark - Instance Methods

- (void) play;
- (void) pause;
- (void) stop;
- (void) togglePlayer;
- (void) seekToTime:(CMTime)time;

@property (nonatomic, readonly) CMTime currentTime;
@property (nonatomic, readonly) CMTime duration;

#pragma mark -
#pragma mark - Static Methods

+ (SSURadioStreamer *) sharedInstance;
+ (void) setSharedInstance:(SSURadioStreamer *)sharedInstance;

@end
