//
//  QWaveformPlayer.m
//  QWaveformRecorder
//
//  Created by NguyenTheQuan on 2014/04/08.
//

#import "QWaveformPlayer.h"

@implementation QWaveformPlayer

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
    [self setNeedsDisplay];
    _playTime = 0.0f;
    _audioFilePath = filePath;
    
    NSURL *url = [NSURL fileURLWithPath:_audioFilePath];
    NSError *error = nil;
	_player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	_player.numberOfLoops = 0;
    [_player prepareToPlay];
    _player.meteringEnabled = YES;
	if (_player == nil)
    {
        NSLog(@"player: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @""
								   message: [error localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    CGFloat duration = _player.duration;
    _waveUpdateFrequency = duration/(SOUND_METER_COUNT/2);
	[_player play];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_waveUpdateFrequency target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void)updateMeters
{
    [_player updateMeters];
    if ((![_player isPlaying]) || (_playTime >= 60.0f)) { //60s
        [self stop];
        return;
    }
    _playTime = _player.currentTime;
    
    [self addSoundMeterItem:[_player averagePowerForChannel:0]];
}

- (void)stop
{
    [_player stop];
    [_timer invalidate];
    [self setNeedsDisplay];
}

- (void)pause
{
    [_player pause];
    [_timer invalidate];
    [self setNeedsDisplay];
}

- (void)continuePlay
{
    [_player play];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_waveUpdateFrequency target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    [self setNeedsDisplay];
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
