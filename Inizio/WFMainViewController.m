//
//  WFMainViewController.m
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "WFMainViewController.h"
#import "WFSubtitleLabel.h"
#import "WFStarButton.h"
#import "WFCards.h"

@import AVKit;
@import AVFoundation;
@import AFNetworking;
@import ZipArchive;

@interface WFMainViewController ()
@property (weak, nonatomic) IBOutlet UIView *movieTop;

@property (weak, nonatomic) IBOutlet WFStarButton *starButton;
@property (weak, nonatomic) IBOutlet WFSubtitleLabel *subtitle;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgress;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movie1WidthAR;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movie1WidthCC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movie1WidthRC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movie1TopAC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movie1CenterYCR;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleWidthAA;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleHeightCR;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleHeightCC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleHeightRA;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starLeadingAC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starTrailingAR;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starVerticalSpaceSubtitleAR;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderCenterXOffsetAC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderVerticalOffsetAR;

@property (nonatomic, readwrite, strong) UIButton *movieControlView;
@property (nonatomic, readwrite, strong) UIView *currentCard;
@property (nonatomic, readwrite, strong) NSArray<UIView *> *viewArray;
@property (nonatomic, readwrite, strong) UIImageView *movieSnapView;
@property (nonatomic, readwrite, strong) AVPlayerViewController *moviePlayerController;

@property (nonatomic, readwrite, strong) WFCards *cards;

@property (nonatomic, readwrite, strong) NSString *lastClipName;

@property (nonatomic, readwrite, assign) CGPoint initLocation;

@end

@implementation WFMainViewController

#pragma mark - property

- (UIButton *)movieControlView
{
    if (_movieControlView == nil)
    {
        _movieControlView = [UIButton buttonWithType:UIButtonTypeCustom];
        _movieControlView.backgroundColor = [UIColor clearColor];
        _movieControlView.layer.anchorPoint = CGPointMake(0.5, 1);
        [_movieControlView addTarget:self action:@selector(changeCurrentMovieState:) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *flipDownCurrentCardGuesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(flipDownCurrentCard:)];
        flipDownCurrentCardGuesture.maximumNumberOfTouches = 1;
        flipDownCurrentCardGuesture.minimumNumberOfTouches = 1;
        
        [_movieControlView addGestureRecognizer:flipDownCurrentCardGuesture];
        
        _movieControlView.layer.zPosition = 100;
    }
    return _movieControlView;
}

- (UIImageView *)movieSnapView
{
    if (_movieSnapView == nil)
    {
        _movieSnapView = [[UIImageView alloc] initWithImage:[self imageFromFile: self.cards.currentCardPicName]];
        _movieSnapView.layer.borderWidth = 3;
        _movieSnapView.layer.borderColor = [UIColor whiteColor].CGColor;
        _movieSnapView.layer.anchorPoint = CGPointMake(0.5, 1);
        _movieSnapView.layer.zPosition = 200;
    }
    return _movieSnapView;
}

- (AVPlayerViewController *)moviePlayerController
{
    if (_moviePlayerController == nil)
    {
        _moviePlayerController = [[AVPlayerViewController alloc] init];
        
        AVPlayer *moviePlayer = [[AVPlayer alloc] initWithURL:self.cards.currentMovieURL];
        moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        _moviePlayerController.player = moviePlayer;
        _moviePlayerController.view.layer.borderWidth = 3.0;
        _moviePlayerController.view.layer.borderColor = [UIColor whiteColor].CGColor;
        _moviePlayerController.view.layer.zPosition = 300;
        _moviePlayerController.view.hidden = YES;
        _moviePlayerController.showsPlaybackControls = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runLoopMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return _moviePlayerController;
}

- (NSArray<UIView *> *)viewArray
{
    if (_viewArray.count == 0)
    {
        NSMutableArray *viewMutableArray = [NSMutableArray arrayWithCapacity:6];
        
        for (NSUInteger index=0; index<6; ++index)
        {
            UIView *currentView = [[UIView alloc] init];
            currentView.userInteractionEnabled = NO;
            currentView.backgroundColor = [UIColor whiteColor];
            currentView.layer.anchorPoint = CGPointMake(0.5, 1);
            
            [viewMutableArray addObject:currentView];
            
            [self.view addSubview:currentView];
        }
        
        _viewArray = [viewMutableArray copy];
        _viewArray.lastObject.alpha = 0;
    }
    return _viewArray;
}

- (void)setCurrentCard:(UIView *)currentCard
{
    self.starButton.isStarred = NO;
    [self.moviePlayerController.player pause];
    [self.moviePlayerController.player.currentItem seekToTime:kCMTimeZero];
    self.moviePlayerController.view.hidden = YES;
    [self.moviePlayerController.view removeFromSuperview];
    
    _currentCard = currentCard;
    
    self.subtitle.text = self.cards.currentCardSubtitle;
//    self.starButton.isStarred = self.cards.current
    
    AVPlayer *moviePlayer = [[AVPlayer alloc] initWithURL:self.cards.currentMovieURL];
    moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    self.moviePlayerController.player = moviePlayer;
    
    [_currentCard addSubview:self.moviePlayerController.view];
    [_currentCard addSubview:self.movieSnapView];
}

#pragma mark - view life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.cards = [WFCards shared];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview: self.movieControlView];
    self.currentCard = self.viewArray.firstObject;
    [self.currentCard insertSubview:self.movieSnapView atIndex:0];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    self.movie1WidthAR.constant = -6;
    self.movie1WidthRC.constant = 1908 / scale;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if ((screenWidth == 568) || (screenHeight == 568))
    {
        self.movie1CenterYCR.constant = 40;
        self.movie1TopAC.constant = 70;
        self.subtitleHeightCC.constant = 73;
        self.sliderVerticalOffsetAR.constant = 20;
        self.movie1WidthCC.constant = 420;
        self.subtitleHeightCR.constant = 108;
        self.starVerticalSpaceSubtitleAR.constant = -12;
    }
    else if ((screenWidth == 480) || (screenWidth == 480))
    {
        self.movie1CenterYCR.constant = 30;
        self.movie1TopAC.constant = 70;
        self.subtitleHeightCC.constant = 80;
        self.sliderVerticalOffsetAR.constant = 5;
        self.movie1WidthCC.constant = 400;
        self.subtitleHeightCR.constant = 100;
        self.starVerticalSpaceSubtitleAR.constant = 0;
    }
    else
    {
        self.movie1CenterYCR.constant = 0;
        self.movie1TopAC.constant = 170/scale;
        self.subtitleHeightCC.constant = 174/scale;
        self.sliderVerticalOffsetAR.constant = 20;
        self.movie1WidthCC.constant = 948/scale;
        self.subtitleHeightCR.constant = 108;
        self.starVerticalSpaceSubtitleAR.constant = -12;
    }
    
    self.subtitleWidthAA.constant = -10;
    self.subtitleHeightRA.constant = 87;
    
    self.starLeadingAC.constant = (self.view.frame.size.width-self.subtitle.frame.size.width)/4-self.starButton.frame.size.width/2;
    self.starTrailingAR.constant = -18/scale;
    
    self.sliderCenterXOffsetAC.constant = (self.view.frame.size.width-self.movieTop.frame.size.width-self.movieTop.frame.origin.x) / 2;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    for (NSUInteger index=0; index<self.viewArray.count; ++index)
    {
        UIView *currentView = self.viewArray[index];
        [self transformView:currentView atIndex:0];
        currentView.frame = self.movieTop.frame;
        [self transformView:currentView atIndex:index];
    }
    
    self.movieControlView.frame = self.movieTop.frame;
    self.movieSnapView.frame = self.movieTop.bounds;
    self.moviePlayerController.view.frame = self.movieTop.bounds;
    
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact)
    {
        self.slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    else if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular)
    {
        self.slider.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - notification selector

- (void)runLoopMovie: (NSNotification *)notification
{
    AVPlayerItem *playerItem = notification.object;
    [playerItem seekToTime:kCMTimeZero];
    [self.moviePlayerController.player play];
    self.moviePlayerController.player.rate = self.slider.value;
}

- (void)changeCurrentMovieState: (UIButton *)button
{
    if ([self.subtitle.text isEqualToString:@"点击上面图片下载更多"])
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.downloadProgress.alpha = 1;
        
        NSString *zipNeedDownload = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastClipNameKey"];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ocpt3gb82.bkt.clouddn.com/%@", zipNeedDownload]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.downloadProgress setProgress:downloadProgress.fractionCompleted animated:YES];
            });
            
            if (downloadProgress.completedUnitCount == downloadProgress.totalUnitCount)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.downloadProgress setProgress:0.0 animated:YES];
                    self.downloadProgress.alpha = 0;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                });
            }
        
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error == nil)
            {
                NSString *destination = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                
                [SSZipArchive unzipFileAtPath:filePath.path toDestination:destination];
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
                
                NSInteger index = [[zipNeedDownload stringByDeletingPathExtension] integerValue];
                
                [self.cards markDidDownloadClip:NSMakeRange(5*index-4, 5*index)];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%zd.zip", index+1] forKey:@"LastClipNameKey"];
            }
            else
            {
                NSLog(@"Error: %@", error);
            }
        }];
        [downloadTask resume];
    }
    else
    {
        if (self.moviePlayerController.view.hidden)
        {
            self.moviePlayerController.view.hidden = NO;
            [self.moviePlayerController.player play];
            self.moviePlayerController.player.rate = self.slider.value;
        }
        else
        {
            self.moviePlayerController.view.hidden = YES;
            [self.moviePlayerController.player pause];
            [self.moviePlayerController.player.currentItem seekToTime:kCMTimeZero];
        }
    }
}

- (void)flipDownCurrentCard: (UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.initLocation = [panGesture locationInView:self.movieControlView];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat angle = [self panMoveAngle:panGesture];
            if (angle < 0)
            {
                [self rotateDownWithAngle:angle withDuration:0.01 withCompletion:nil];
            }
            else
            {
                [self rotateUpWithAngle:angle withDuration:0.01 withCompletion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            CGFloat angle = [self panMoveAngle:panGesture];
            if (angle >= 0)
            {
                CGFloat flipAngle = M_PI / 3;
                if (angle > flipAngle)
                {
                    [self rotateUpWithAngle:M_PI withDuration:0.3 withCompletion:^(BOOL finished) {
                        if (finished)
                        {
                            [UIView animateWithDuration:0.1 animations:^{
                                self.currentCard.alpha = self.currentCard.alpha;
                            } completion:^(BOOL finished) {
                                if (finished)
                                {
                                    UIView *currentView = self.viewArray.lastObject;
                                    NSMutableArray<UIView *> *tempViewArray = [NSMutableArray arrayWithArray:self.viewArray];
                                    [tempViewArray removeLastObject];
                                    [tempViewArray insertObject:currentView atIndex:0];
                                    self.viewArray = [tempViewArray copy];
                                    self.currentCard = self.viewArray.firstObject;
                                }
                            }];
                        }
                    }];
                }
                else
                {
                    [self rotateUpWithAngle:0 withDuration:0.3 withCompletion: nil];
                }
            }
            else
            {
                CGFloat flipAngle = M_PI / 3;
                angle = -angle;
                
                if (angle > flipAngle)
                {
                    [self rotateDownWithAngle:-M_PI withDuration:0.3 withCompletion:^(BOOL finished) {
                        if (finished)
                        {
                            [UIView animateWithDuration:0.1 animations:^{
                                self.currentCard.alpha = 0;
                            } completion:^(BOOL finished) {
                                if (finished)
                                {
                                    UIView *currentView = self.viewArray.firstObject;
                                    NSMutableArray<UIView *> *tempViewArray = [NSMutableArray arrayWithArray:self.viewArray];
                                    [tempViewArray removeObjectAtIndex:0];
                                    [tempViewArray addObject:currentView];
                                    self.viewArray = [tempViewArray copy];
                                    self.currentCard = self.viewArray.firstObject;
                                }
                            }];
                        }
                    }];
                }
                else
                {
                    [self rotateDownWithAngle:0 withDuration:0.1 withCompletion:nil];
                }
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

- (IBAction)didHitStar:(WFStarButton *)sender
{
    sender.isStarred = !sender.isStarred;
//    self.cards.starCurrentCard(star: sender.isStarred)
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    //TODO: 如果影片没播放，改动这个，影片会开始播放
    self.moviePlayerController.player.rate = sender.value;
}

#pragma mark - private transfrom

- (void)transformView: (UIView *)view atIndex: (NSUInteger)index
{
    view.layer.zPosition = -100.0 * index;
    
    CGFloat offset = 1-0.06*index;
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, offset, offset);
    transform = CGAffineTransformTranslate(transform, 0, -35.0*index);
    view.transform = transform;
    view.alpha = 0.5 - 0.1 * index;
    if (index == (self.viewArray.count - 1)) { view.alpha = 0; }
    if (index == 0) { view.alpha = 1; }
}

- (UIImage *)imageFromFile: (NSString *)imageName
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentPath, imageName]];
}

- (CGFloat)panMoveAngle: (UIPanGestureRecognizer *)panGesture
{
    CGPoint location = [panGesture locationInView: self.movieControlView];
    CGFloat path = location.y - self.initLocation.y;
    return -path / (CGRectGetHeight(self.movieControlView.frame)*2) * (M_PI);
}

- (CGFloat)scaleOffsetIndex: (NSInteger)index
{
    return 1-0.06*index;
}

- (CGFloat)translateOffsetIndex: (NSInteger)index
{
    return -index*35.0;
}

- (CGFloat)alphaOffsetIndex: (NSInteger)index
{
    if (index == (self.viewArray.count-1)) { return 0; }
    if (index == 0) { return 1; }
    return 0.5-index*0.1;
}

- (void)rotateDownWithAngle: (CGFloat)angle withDuration: (NSTimeInterval)duration withCompletion: (void (^)(BOOL finished))completion
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/500;
    transform = CATransform3DRotate(transform, angle, 1, 0, 0);
    
    UIView *previousView = self.viewArray.lastObject;
    previousView.layer.zPosition = -100.0 * (self.viewArray.count - 1);
    
    if (angle <= -M_PI_2)
    {
        if (self.movieSnapView.superview != self.viewArray[1])
        {
            [self.movieSnapView removeFromSuperview];
            self.movieSnapView.image = [self imageFromFile:[self.cards snapShotNameAtIndex:self.cards.next]];
            self.movieSnapView.alpha = 0;
            [self.viewArray[1] insertSubview:self.movieSnapView atIndex:0];
        }
        [UIView animateWithDuration:duration animations:^{
            self.movieSnapView.alpha = -(M_PI_2+angle)/M_PI_2;
        }];
    }
    else if ((angle >= -M_PI_2) && (self.movieSnapView.superview != self.currentCard))
    {
        [self.movieSnapView removeFromSuperview];
        self.movieSnapView.image = [self imageFromFile:[self.cards snapShotNameAtIndex:self.cards.previous]];
        self.movieSnapView.alpha = 1;
        [self.currentCard insertSubview:self.movieSnapView atIndex:0];
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.currentCard.layer.transform = transform;
        
        for (NSUInteger index=1; index<self.viewArray.count; ++index)
        {
            UIView *animationView = self.viewArray[index];
            
            NSInteger tempIndex = index - 1;
            CGAffineTransform transform = CGAffineTransformIdentity;
            CGFloat degree = -angle / M_PI;
            
            CGFloat scaleTransform = ([self scaleOffsetIndex:tempIndex]-[self scaleOffsetIndex:index])*degree+[self scaleOffsetIndex:index];
            CGFloat translateTransform = ([self translateOffsetIndex:tempIndex]-[self translateOffsetIndex:index])*degree+[self translateOffsetIndex:index];
            CGFloat alphaTransform = ([self alphaOffsetIndex:tempIndex]-[self alphaOffsetIndex:index])*degree+[self alphaOffsetIndex:index];
            
            transform = CGAffineTransformScale(transform, scaleTransform, scaleTransform);
            transform = CGAffineTransformTranslate(transform, 0, translateTransform);
            animationView.transform = transform;
            animationView.alpha = alphaTransform;
        }
    } completion: completion];
}

- (void)rotateUpWithAngle: (CGFloat)angle withDuration: (NSTimeInterval)duration withCompletion: (void (^)(BOOL finished))completion
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/500;
    transform = CATransform3DRotate(transform, angle-M_PI, 1, 0, 0);
    
    UIView *previousView = self.viewArray.lastObject;
    previousView.layer.zPosition = 0;
    
    if ((angle >= M_PI_2) && (self.movieSnapView.superview != self.viewArray.lastObject))
    {
        [self.movieSnapView removeFromSuperview];
        self.movieSnapView.image = [self imageFromFile:[self.cards snapShotNameAtIndex:self.cards.previous]];
        self.movieSnapView.alpha = 1;
        [self.viewArray.lastObject insertSubview:self.movieSnapView atIndex:0];
    }
    else if (angle <= M_PI_2)
    {
        if (self.movieSnapView.superview != self.currentCard)
        {
            [self.movieSnapView removeFromSuperview];
            self.movieSnapView.image = [self imageFromFile:[self.cards snapShotNameAtIndex:self.cards.next]];
            self.movieSnapView.alpha = 0;
            [self.currentCard insertSubview:self.movieSnapView atIndex:0];
        }
        [UIView animateWithDuration:duration animations:^{
            self.movieSnapView.alpha = (M_PI_2-angle)/M_PI_2;
        }];
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        previousView.layer.transform = transform;
        previousView.alpha = angle/M_PI_2;
        
        for (NSUInteger index=0; index<self.viewArray.count-1; ++index)
        {
            UIView *animationView = self.viewArray[index];
            
            NSInteger tempIndex = index + 1;
            CGAffineTransform transform = CGAffineTransformIdentity;
            CGFloat degree = angle / M_PI;
            
            CGFloat scaleTransform = ([self scaleOffsetIndex:tempIndex]-[self scaleOffsetIndex:index])*degree+[self scaleOffsetIndex:index];
            CGFloat translateTransform = ([self translateOffsetIndex:tempIndex]-[self translateOffsetIndex:index])*degree+[self translateOffsetIndex:index];
            CGFloat alphaTransform = ([self alphaOffsetIndex:tempIndex]-[self alphaOffsetIndex:index])*degree+[self alphaOffsetIndex:index];
            
            transform = CGAffineTransformScale(transform, scaleTransform, scaleTransform);
            transform = CGAffineTransformTranslate(transform, 0, translateTransform);
            animationView.transform = transform;
            animationView.alpha = alphaTransform;
            animationView.layer.zPosition =  -100.0 * (index+1);
        }
    } completion: completion];
}

@end
