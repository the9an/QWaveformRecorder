//
//  QWaveformRecorder.m
//  QWaveformRecorder
//
//  Created by NguyenTheQuan on 2014/04/07.
//

#import "QWaveformRecorder.h"

@implementation QWaveformRecorder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        _meterWaveColor = [UIColor whiteColor];
        _isMeterRight = YES;
        
        _frameRect = frame;
        //fill empty sound meters
        for (int i = 0; i < SOUND_METER_COUNT; i++) {
            _soundMeters[i] = MAX_LENGTH_OF_WAVE;
        }
    }
    return self;
}

- (void)startForFilePath:(NSString *)filePath
{
    _recordTime = 0.0f;
    
    [self setNeedsDisplay];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if (err) {
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    if (err) {
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    _recordSetting = [[NSMutableDictionary alloc] init];
	
	// You can change the settings for the voice quality
//	[_recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
//	[_recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
//	[_recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
//    [_recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//    [_recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
//    [_recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];  
//    [_recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//    [_recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//    [_recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    [_recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [_recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [_recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    _recorderFilePath = filePath;
    NSURL *url = [NSURL fileURLWithPath:_recorderFilePath];
    err = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:_recordSetting error:&err];
    if (!_recorder) {
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @""
								   message: [err localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [_recorder setDelegate:self];
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
    
    if (!audioSession.inputAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Audio input hardware not available"
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    [_recorder recordForDuration:(NSTimeInterval)60]; //record duration 60s
    _timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (BOOL)recording
{
    if (_recorder) {
        return _recorder.recording;
    }
    
    return NO;
}

- (void)updateMeters
{
    [_recorder updateMeters];
    //NSLog(@"meter:%5f", [_recorder averagePowerForChannel:0]);
    if (([_recorder averagePowerForChannel:0] < -60.0) || (_recordTime >= 60.0f)) { //60s
        [self commitRecording];
        return;
    }
    _recordTime = _recorder.currentTime;
    //NSLog(@"Record time %f",_recordTime);
    if (self.delegate && [self.delegate respondsToSelector:@selector(QWaveformRecorder:currentRecordingTime:)])
    {
        [self.delegate QWaveformRecorder:self currentRecordingTime:_recordTime];
    }
    
    [self addSoundMeterItem:[_recorder averagePowerForChannel:0]];
}

- (void)stopRecording
{
    [self commitRecording];
}

- (void)commitRecording
{
    [_recorder stop];
    [_timer invalidate];
    
    if (self.delegate && ([self.delegate respondsToSelector:@selector(QWaveformRecorderDidEndRecord:voiceRecordedPath:length:)])) {
        [self.delegate QWaveformRecorderDidEndRecord:self voiceRecordedPath:_recorderFilePath length:_recordTime];
    }
    
    [self setNeedsDisplay];
}

- (void)cancelRecording
{
    [self setNeedsDisplay];
    [_timer invalidate];
    
    if (self.delegate && ([self.delegate respondsToSelector:@selector(QWaveformRecorderDidCancelRecord:)])) {
        [self.delegate QWaveformRecorderDidCancelRecord:self];
    }
    
    [_recorder stop];
    unlink([_recorderFilePath UTF8String]);
}

#pragma mark - Sound meter operations
- (void)shiftSoundMeterLeft
{
    for(int i = 0; i < SOUND_METER_COUNT - 1; i++) {
        _soundMeters[i] = _soundMeters[i+1];
    }
}

- (void)shiftSoundMeterRight
{
    for(int i = SOUND_METER_COUNT - 1; i >= 0 ; i--) {
        _soundMeters[i] = _soundMeters[i-1];
    }
}

- (void)addSoundMeterItem:(int)lastValue
{
    if (_isMeterRight) {
        [self shiftSoundMeterRight];
        [self shiftSoundMeterRight];
        _soundMeters[0] = lastValue;
        _soundMeters[1] = lastValue;
    }
    else {
        [self shiftSoundMeterLeft];
        [self shiftSoundMeterLeft];
        _soundMeters[SOUND_METER_COUNT - 1] = lastValue;
        _soundMeters[SOUND_METER_COUNT - 2] = lastValue;
    }
    
    [self setNeedsDisplay];
}


#pragma mark - Drawing operations
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Draw sound meter wave
    [_meterWaveColor set];
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    int baseLine = _frameRect.size.height/2;
    int multiplier = 1;
    int maxValueOfMeter = _frameRect.size.height/2 - 5;
    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--)
    {
        multiplier = ((int)x % 2) == 0 ? 1 : -1;
        
        CGFloat y = baseLine + ((maxValueOfMeter * (MAX_LENGTH_OF_WAVE - abs(_soundMeters[(int)x]))) / MAX_LENGTH_OF_WAVE) * multiplier;
        
        if(x == SOUND_METER_COUNT - 1) {
            CGContextMoveToPoint(context, x * (_frameRect.size.width / SOUND_METER_COUNT), y);
            //CGContextAddLineToPoint(context, x * (_frameRect.size.width / SOUND_METER_COUNT) + 1, y);
        }
        else {
            CGContextAddLineToPoint(context, x * (_frameRect.size.width / SOUND_METER_COUNT), y);
            //CGContextAddLineToPoint(context, x * (_frameRect.size.width / SOUND_METER_COUNT) + 1, y);
        }
    }
    
    CGContextStrokePath(context);
}

@end
