//
//  ViewController.m
//  LHWComics
//
//  Created by Hanguang on 04/01/2017.
//  Copyright © 2017 Hanguang. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "LHWComicBook.h"
#import "MainTableViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomVIew;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *aliasLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *sogaButton;
@property (nonatomic, strong) LHWComicBook *book;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *converViewTC;

@end

@implementation ViewController {
    BOOL _isFirstLoaded;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoaded = YES;
    self.sogaButton.layer.borderColor = [UIColor colorWithRed:40./255 green:40./255 blue:42./255. alpha:1.0].CGColor;
    [self refreshUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.converViewTC.constant = 0;
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)refreshUI {
    [self startAnimation];
    
    __weak typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:kOnePunchMan] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (data && error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (dict) {
                strongSelf.book = [[LHWComicBook alloc] initWithData:dict];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAnimation];
                    [self updateData];
                });
            }
        }
    }];
    
    [task resume];
}

- (void)updateData {
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:_book.cover_img]];
    self.title = _book.bookName;
    _authorLabel.text = _book.author;
    _aliasLabel.text = _book.alias;
    _statusLabel.text = _book.status;
    if (!_isFirstLoaded) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomVIew.alpha = 0.0;
        }];
    }
}

- (IBAction)hideCoverView:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.converViewTC.constant = -440;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            if (_isFirstLoaded) {
                _isFirstLoaded = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    self.bottomVIew.alpha = 0.0;
                }];
            }
        }
    }];
}

- (void)startAnimation {
    CABasicAnimation *rotationLoaderImageView = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationLoaderImageView.toValue = @(-M_PI * 2.f);
    rotationLoaderImageView.duration = 1.f;
    rotationLoaderImageView.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationLoaderImageView.cumulative = YES;
    rotationLoaderImageView.repeatCount = HUGE_VAL;
    rotationLoaderImageView.fillMode = kCAFillModeForwards;
    rotationLoaderImageView.autoreverses = NO;
    
    [_logoImageView.layer addAnimation:rotationLoaderImageView forKey:@"rotateAnimation"];
}

- (void)stopAnimation {
    [_logoImageView.layer removeAnimationForKey:@"rotateAnimation"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainTableViewController"]) {
        MainTableViewController *dest = segue.destinationViewController;
        dest.book = _book;
    }
}

@end
