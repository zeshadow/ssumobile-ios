//
//  RadioViewController.h
//  SSUMobile
//
//  Created by Eric Amorde on 9/21/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "SSURadioStreamer.h"


@interface SSURadioViewController : UIViewController <SSURadioStreamerDelegate>

/**
 @name IBOutlets
 */
@property (nonatomic, weak) IBOutlet UIImageView * mainImage;
@property (nonatomic, weak) IBOutlet UIButton * button;
@property (nonatomic, weak) IBOutlet UILabel * elapsedLabel;
@property (nonatomic, weak) IBOutlet UISlider * progressSlider;
@property (nonatomic, weak) IBOutlet UIView * volumeSlider;
@property (nonatomic, weak) IBOutlet UIImageView * speakerImage;

/**
 @name Other properties
 */
@property (nonatomic, strong) SSURadioStreamer * streamer;

/**
 @name IBActions
 */
- (IBAction)buttonPressed:(id)sender;
- (IBAction)sliderMoved:(UISlider *)aSlider;

@end
