//
//  MainViewController.m
//  QWaveformRecorder
//
//  Created by NguyenTheQuan on 2014/04/07.
//  Copyright (c) 2014年 kayac. All rights reserved.
//

#import "MainViewController.h"
#import "QWaveformRecorder.h"
#import "QWaveformPlayer.h"

@interface MainViewController () <QWaveformRecorderDelegate>
{
    QWaveformRecorder *_recorder;
    QWaveformPlayer *_player;
}

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *viewRecord = [[UIView alloc] initWithFrame:CGRectMake(0, 260, 320, 160)];
    viewRecord.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:viewRecord];
    
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake(110, 315, 100, 50);
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    recordButton.backgroundColor = [UIColor whiteColor];
    recordButton.showsTouchWhenHighlighted = YES;
    [recordButton addTarget:self action:@selector(recording:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recording:(id)sender
{
    UIButton *recordButton = (UIButton *)sender;
    if ([recordButton.titleLabel.text isEqualToString:@"Record"]) {
        [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        if (_player) {
            [_player removeFromSuperview];
            _player = nil;
        }
        _recorder = [[QWaveformRecorder alloc] initWithFrame:CGRectMake(0, 260, 320, 160)];
        _recorder.delegate = self;
        _recorder.meterWaveColor = [UIColor yellowColor];
        _recorder.userInteractionEnabled = NO;
        [self.view addSubview:_recorder];
        [self.view bringSubviewToFront:recordButton];
        [_recorder startForFilePath:[NSString stringWithFormat:@"%@/Documents/testSound.m4a", NSHomeDirectory()]];
    }
    else if ([recordButton.titleLabel.text isEqualToString:@"Stop"]) {
        [recordButton setTitle:@"Play" forState:UIControlStateNormal];
        [_recorder stopRecording];
    }
    else if ([recordButton.titleLabel.text isEqualToString:@"Play"]) {
        [recordButton setTitle:@"Pause" forState:UIControlStateNormal];
        
        if (_recorder) {
            [_recorder removeFromSuperview];
            _recorder = nil;
        }
        
        _player = [[QWaveformPlayer alloc] initWithFrame:CGRectMake(0, 260, 320, 160)];
        _player.meterWaveColor = [UIColor whiteColor];
        _player.userInteractionEnabled = NO;
        [self.view addSubview:_player];
        [self.view bringSubviewToFront:recordButton];
        [_player startForFilePath:[NSString stringWithFormat:@"%@/Documents/testSound.m4a", NSHomeDirectory()]];
    }
    else if ([recordButton.titleLabel.text isEqualToString:@"Pause"]) {
        [recordButton setTitle:@"Record" forState:UIControlStateNormal];
        [_player stop];
    }
}

#pragma mark - QWaveformRecorderDelegate
- (void)QWaveformRecorderDidEndRecord:(QWaveformRecorder *)qwRecorder voiceRecordedPath:(NSString *)recordPath length:(float)recordLength
{
    NSLog(@"Sound recorded with file %@ for %.2f seconds", [recordPath lastPathComponent], recordLength);
}

- (void)QWaveformRecorderDidCancelRecord:(QWaveformRecorder *)qwRecorder 
{
    NSLog(@"Voice recording cancelled for: %@", qwRecorder);
}
@end
