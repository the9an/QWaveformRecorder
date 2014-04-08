//
//  MainViewController.m
//  QWaveformRecorder
//
//  Created by NguyenTheQuan on 2014/04/07.
//  Copyright (c) 2014年 kayac. All rights reserved.
//

#import "MainViewController.h"
#import "QWaveformRecorder.h"

@interface MainViewController () <QWaveformRecorderDelegate>
{
    QWaveformRecorder *_recorder;
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
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake(100, 100, 100, 100);
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    recordButton.backgroundColor = [UIColor whiteColor];
    [recordButton addTarget:self action:@selector(recording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recording
{
    if (!_recorder) {
        _recorder = [[QWaveformRecorder alloc] initWithFrame:CGRectMake(0, 260, 320, 160)];
        _recorder.delegate = self;
        [self.view addSubview:_recorder];
    }
    
    [_recorder startForFilePath:[NSString stringWithFormat:@"%@/Documents/testSound.m4a", NSHomeDirectory()]];
}

#pragma mark - QWaveformRecorderDelegate
- (void)QWaveformRecorderDidEndRecord:(QWaveformRecorder *)qwRecorder voiceRecordedPath:(NSString *)recordPath length:(float)recordLength
{
    NSLog(@"Sound recorded with file %@ for %.2f seconds", [recordPath lastPathComponent], recordLength);
}

- (void)QWaveformRecorderDidCancelRecord:(QWaveformRecorder *)qwRecorder
{
    NSLog(@"Voice recording cancelled for HUD: %@", qwRecorder);
}
@end
