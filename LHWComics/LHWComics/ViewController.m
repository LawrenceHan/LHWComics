//
//  ViewController.m
//  LHWComics
//
//  Created by Hanguang on 04/01/2017.
//  Copyright © 2017 Hanguang. All rights reserved.
//

#import "ViewController.h"
#import "SDWebImageDownloader.h"
#import "UIImageView+WebCache.h"

NSString * const agent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36";

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomVIew;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController {
    NSString *_refererURL;
    NSString *_coverURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData1:nil];
    [[SDWebImageDownloader sharedDownloader] setValue:agent forHTTPHeaderField:@"User-Agent"];
    [[SDWebImageDownloader sharedDownloader] setValue:_refererURL forHTTPHeaderField:@"Referer"];
}

- (IBAction)loadData1:(UIBarButtonItem *)sender {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"test" ofType:@"json"];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    
    _refererURL = [dict valueForKeyPath:@"url"];
    _coverURL = [dict valueForKeyPath:@"image_urls.@firstObject"];
    NSString *title = [dict valueForKeyPath:@"title"];
    NSString *author = [dict valueForKeyPath:@"author.@firstObject"];
    NSString *status = [dict valueForKeyPath:@"status"];
    NSArray *chapters = [dict valueForKeyPath:@"chapters"];
    
    _titleLabel.text = title;
    _authorLabel.text = author;
    _statusLabel.text = status;
    
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:_coverURL]];
    
    _photos = [NSMutableArray new];
    for (NSDictionary *dict in chapters) {
        NSString *url = [dict valueForKeyPath:@"images.@firstObject"];
        [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
    }
    
    [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://h.hiphotos.baidu.com/zhidao/pic/item/f2deb48f8c5494ee5fd1d9302ff5e0fe99257e2c.jpg"]]];
    [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://static.yingyonghui.com/screenshots/1894/1894123_0.jpg"]]];
    [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://www.07073.com/uploads/140819/9869050_144639_1_lit.jpg"]]];
}

- (IBAction)loadData2:(UIBarButtonItem *)sender {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"test2" ofType:@"json"];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    
    NSString *title = [dict valueForKeyPath:@"title"];
    NSArray *array = [dict valueForKeyPath:@"contents"];
    _titleLabel.text = title;
    
    _photos = [NSMutableArray new];
    for (NSString *string in array) {
        [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:string]]];
    }
}

- (IBAction)loadData3:(UIBarButtonItem *)sender {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"test" ofType:@"json"];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];

    NSString *title = [dict valueForKeyPath:@"title"];
    NSArray *array = [dict valueForKeyPath:@"contents"];
    _titleLabel.text = title;
    
    _photos = [NSMutableArray new];
    for (NSString *string in array) {
        [_photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:string]]];
    }
}

- (IBAction)buttonTouched:(UIButton *)sender {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:0];
    
    // Show
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return NO;
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
