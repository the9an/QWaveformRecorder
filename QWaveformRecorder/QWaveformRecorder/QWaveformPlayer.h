//
//  QWaveformPlayer.h
//  QWaveformRecorder
//
//  Created by NguyenTheQuan on 2014/04/08.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QWaveformDefine.h"

@interface QWaveformPlayer : UIView <AVAudioPlayerDelegate>
{
    int _soundMeters[SOUND_METER_COUNT];
    CGRect _frameRect;
    NSString *_audioFilePath;
    AVAudioPlayer *_player;
    SystemSoundID _soundId;
    NSTimer *_timer;
    float _playTime;
    float _waveUpdateFrequency;
}

@property (nonatomic, retain) UIColor *meterWaveColor;
@property (nonatomic) BOOL isMeterRight;

- (void)startForFilePath:(NSString *)filePath;
- (void)stop;
- (void)pause;
- (void)continuePlay;

@end
