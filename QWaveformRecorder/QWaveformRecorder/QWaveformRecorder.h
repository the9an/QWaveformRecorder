//
//  QWaveformRecorder.h
//  QWaveformRecorder
//
//  Created by NguyenTheQuan on 2014/04/07.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SOUND_METER_COUNT       440
#define WAVE_UPDATE_FREQUENCY   0.272// 60s/ (SOUND_METER_COUNT/2)
#define MAX_LENGTH_OF_WAVE 50

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