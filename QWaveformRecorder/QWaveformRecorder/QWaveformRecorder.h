//
//  QWaveformRecorder.h
//  QWaveformRecorder
//
//  Created by NguyenTheQuan on 2014/04/07.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QWaveformDefine.h"

@protocol QWaveformRecorderDelegate;

@interface QWaveformRecorder : UIView <AVAudioRecorderDelegate>
{
    int _soundMeters[SOUND_METER_COUNT];
    CGRect _frameRect;
    NSMutableDictionary *_recordSetting;
    NSString *_recorderFilePath;
    AVAudioRecorder *_recorder;
    SystemSoundID _soundId;
    NSTimer *_timer;
    float _recordTime;
}

@property (nonatomic, assign) id<QWaveformRecorderDelegate> delegate;
@property (nonatomic, retain) UIColor *meterWaveColor;
@property (nonatomic) BOOL isMeterRight;

- (void)startForFilePath:(NSString *)filePath;
- (void)stopRecording;
- (void)cancelRecording;
- (BOOL)recording;

@end


@protocol QWaveformRecorderDelegate <NSObject>

@optional

- (void)QWaveformRecorder:(QWaveformRecorder *)qwRecorder currentRecordingTime:(float)currentTime;
- (void)QWaveformRecorderDidBeginRecord:(QWaveformRecorder *)qwRecorder;
- (void)QWaveformRecorderDidEndRecord:(QWaveformRecorder *)qwRecorder voiceRecordedPath:(NSString *)recordPath length:(float)recordLength;
- (void)QWaveformRecorderDidCancelRecord:(QWaveformRecorder *)qwRecorder;

@end